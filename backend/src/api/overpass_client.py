# builtin
import requests
from typing import List

# internal
from models import Location

# external
from pydantic import ValidationError

def get_locations_from_overpass(lat: float, long: float) -> List[Location]:

    url = 'http://overpass-api.de/api/interpreter'

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

    params = {'data': overpass_query}

    response = requests.get(url, params=params)
    if response.status_code != 200:
        raise Exception(f"Error fetching data from Overpass API: {response.status_code}")

    data = response.json()
    elements = data.get("elements", [])

    locations = []
    for element in elements:
        if element["type"] == "node":
            try:
                location = Location(
                    name=element.get("tags", {}).get("name"),
                    lat=element["lat"],
                    lon=element["lon"],
                    tags=element.get("tags", {})
                )
                locations.append(location)
            except ValidationError as e:
                print(f"Validation error for element {element['id']}: {e}")
    return locations
