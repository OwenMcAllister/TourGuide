import requests
from models import Location
from typing import List
from pydantic import ValidationError

def get_locations_from_overpass(query: str) -> List[Location]:
    url = 'http://overpass-api.de/api/interpreter'
    params = {'data': query}

    response = requests.get(url, params=params)
    if response.status_code != 200:
        raise Exception(f"Error fetching data from Overpass API: {response.status_code}")

    data = response.json()
    elements = data.get("elements", [])

    # Parse the elements into Location models
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
