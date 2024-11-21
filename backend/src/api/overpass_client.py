# builtin
import aiohttp
from typing import List

# internal
from src.api.models import Location

# external
from pydantic import ValidationError

async def get_locations_from_overpass(lat: float, lon: float, radius_miles: float) -> List[Location]:
    url = 'http://overpass-api.de/api/interpreter'

    overpass_query = f"""
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

    async with aiohttp.ClientSession() as session:
        async with session.get(url, params=params) as response:
            if response.status != 200:
                raise Exception(f"Error fetching data from Overpass API: {response.status}")

            data = await response.json()
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
