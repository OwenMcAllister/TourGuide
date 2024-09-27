from overpass_api import get_locations_from_overpass
from models import LocationResponse
from openai_service import prepare_openai_prompt, get_noteworthy_locations_from_llm
import geopy


#Test lat, long, and radius (miles)

lat = 48.864716
lon = 2.349014

radius_miles = 1

#Set boundingbox for Overpass
def get_bounding_box(latitude: float, longitude: float, radius_miles: float):
    """
    Get the bounding box coordinates (southwest and northeast) for a circular area around the given coordinates.
    The radius is converted to kilometers to match the geopy library.
    
    Parameters:
    - latitude (float): The center latitude of the area.
    - longitude (float): The center longitude of the area.
    - radius_miles (float): The radius around the center point in miles.
    
    Returns:
    - tuple: Bounding box coordinates (south_lat, west_lon, north_lat, east_lon).
    """

    center = (latitude, longitude)
    radius_km = radius_miles * 1.60934

    # Calculate points at the northern, southern, eastern, and western boundaries
    north = geopy.distance.distance(kilometers=radius_km).destination(center, 0)
    south = geopy.distance.distance(kilometers=radius_km).destination(center, 180)
    east = geopy.distance.distance(kilometers=radius_km).destination(center, 90)
    west = geopy.distance.distance(kilometers=radius_km).destination(center, 270)

    return south[0], west[1], north[0], east[1]


#Define bounding box
bbox = get_bounding_box(lat, lon, radius_miles)

#Overpass query
overpass_query =f"""
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

locations = get_locations_from_overpass(overpass_query)

#Create LocationResponse object for validation
location_response = LocationResponse(locations=locations)

#Generate prompt based on locations
prompt = prepare_openai_prompt(location_response.locations)

#Get only noteworthy locations
noteworthy_locations = get_noteworthy_locations_from_llm(prompt)

print(noteworthy_locations)
