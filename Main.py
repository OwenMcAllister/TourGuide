import requests
import geopy.distance
import os
import dotenv
import openai
from landmark import Landmark, LandmarkQueryResponse
from location import Location

dotenv.load_dotenv('.env')

# OpenAI API key from environment
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
openai.api_key = OPENAI_API_KEY

# Overpass API accessing Open Street Map Data
OVERPASS_URL = "http://overpass-api.de/api/interpreter"


def get_bounding_box(latitude: float, longitude: float, radius_miles: float):
    # Center and radius
    center = (latitude, longitude)
    radius_km = radius_miles * 1.60934

    # Geopy circle
    north = geopy.distance.distance(kilometers=radius_km).destination(center, 0)
    south = geopy.distance.distance(kilometers=radius_km).destination(center, 180)
    east = geopy.distance.distance(kilometers=radius_km).destination(center, 90)
    west = geopy.distance.distance(kilometers=radius_km).destination(center, 270)

    return south[0], west[1], north[0], east[1]


def query_osm_landmarks(lat: float, lon: float, radius_miles: float = 1) -> LandmarkQueryResponse:
    # Get the bounding box for a given radius
    bbox = get_bounding_box(lat, lon, radius_miles)
    min_lat, min_lon, max_lat, max_lon = bbox

    # Overpass QL query to retrieve all landmarks within the bounding box
    query = f"""
    [out:json];
    (
      node["tourism"](around:{radius_miles * 1609.34},{lat},{lon});
      node["artwork"](around:{radius_miles * 1609.34},{lat},{lon});
      node["atraction"](around:{radius_miles * 1609.34},{lat},{lon});
      node["garden"](around:{radius_miles * 1609.34},{lat},{lon});
      node["historic"](around:{radius_miles * 1609.34},{lat},{lon});
      node["landmark"](around:{radius_miles * 1609.34},{lat},{lon});
      node["memorial"](around:{radius_miles * 1609.34},{lat},{lon});
      node["natural"](around:{radius_miles * 1609.34},{lat},{lon})["natural"!~"tree"];
    );
    out body;
    """

    # Make the request to the Overpass API
    response = requests.get(OVERPASS_URL, params={'data': query})
    data = response.json()

    # Extract all the landmarks from the response
    landmarks = []
    for element in data['elements']:
        name = element['tags'].get('name')
        if name:
            landmark_type = ', '.join([f"{k}={v}" for k, v in element['tags'].items()])
            lat = element['lat']
            lon = element['lon']
            landmarks.append(Landmark(
                name=name,
                type=landmark_type,
                latitude=lat,
                longitude=lon
            ))

    return LandmarkQueryResponse(landmarks=landmarks)


def query_gpt(message: str):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "system",
                "content": "Return the top 10 most interesting locations. Format as: '[LocationName1, CategoryTag1, Latitude1, Longitude1], [LocationName2, CategoryTag2, Latitude2, Longitude2],...'"
            },
            {
                "role": "user",
                "content": message
            }
        ],
        max_tokens=1000,
        temperature=0.2
    )

    return response.choices[0].message['content']


# Testing
latitude = 45.9237
longitude = 6.8694
radius = 5  # In miles

landmarks = query_osm_landmarks(latitude, longitude, radius)

query_string = ""

for landmark in landmarks.landmarks:
    query_string += f"Landmark: {landmark.name}, Type: {landmark.type}, Location: ({landmark.latitude}, {landmark.longitude})"

# Call OpenAI to process the landmarks
result = query_gpt(query_string)
print(result)
