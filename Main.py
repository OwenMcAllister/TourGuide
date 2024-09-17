import requests
import geopy.distance
import LocationNode
import os
import dotenv

dotenv.load_dotenv('.env')

#Perplexity
KEY = os.getenv('API_KEY')
PERP_URL = "https://api.perplexity.ai/chat/completions"

#Overpass API accessing Open Street Map Data
OVERPASS_URL = "http://overpass-api.de/api/interpreter"

def get_bounding_box(latitude, longitude, radius_miles):

    #Center and radius
    center = (latitude, longitude)
    
    radius_km = radius_miles * 1.60934

    #Geopy circle
    north = geopy.distance.distance(kilometers=radius_km).destination(center, 0)
    south = geopy.distance.distance(kilometers=radius_km).destination(center, 180)
    east = geopy.distance.distance(kilometers=radius_km).destination(center, 90)
    west = geopy.distance.distance(kilometers=radius_km).destination(center, 270)
    
    return south[0], west[1], north[0], east[1]

def query_osm_landmarks(lat, lon, radius_miles=1):
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
        if name != None:
            landmark_type = ', '.join([f"{k}={v}" for k, v in element['tags'].items()])
            lat = element['lat']
            lon = element['lon']
            landmarks.append({
                'name': name,
                'type': landmark_type,
                'latitude': lat,
                'longitude': lon
        })
    
    return landmarks


#Get noteworthy landmarks from GPT and create landmark objects
def query_gpt(message):

    payload = {
        "model": "llama-3.1-sonar-large-128k-chat",
        "messages": [
            {
                "role": "system",
                "content": "With the pasted text, return a list of the top 10 most interesting locations. Format the data to look like the following: '[LocationName1, CategoryTag1, Latitude1, Longitude1], [LocationName2, CategoryTag2, Latitude2, Longitude2],...' YOU CAN NOT include any additional commentary or text, before OR after the data output."
            },
            {
                "role": "user",
                "content": message
            }
        ],
        "max_tokens": 1000,
        "temperature": 0.2,
        "top_p": 0.9,
        "return_citations": False,
        "search_domain_filter": ["perplexity.ai"],
        "return_images": False,
        "return_related_questions": False,
        "search_recency_filter": "month",
        "top_k": 0,
        "stream": False,
        "presence_penalty": 0,
        "frequency_penalty": 1
    }
    headers = {
        "Authorization": f"Bearer {KEY}",
        "Content-Type": "application/json"
    }

    response = requests.request("POST", PERP_URL, json=payload, headers=headers)

    print(response.text)



#Testing
latitude = 45.9237
longitude = 6.8694

#In miles
radius = 5 

landmarks = query_osm_landmarks(latitude, longitude, radius)

query_string =  ""

for landmark in landmarks:
    query_string += f"Landmark: {landmark['name']}, Type: {landmark['type']}, Location: ({landmark['latitude']}, {landmark['longitude']})"

query_gpt(query_string)

#print(query_string)