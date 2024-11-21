# built in
from typing import Tuple

# external
from geopy.distance import distance

async def get_bounding_box(latitude: float, longitude: float, radius_miles: float) -> Tuple[float, float, float, float]:
    center = (latitude, longitude)
    radius_km = radius_miles * 1.60934

    north = distance(kilometers=radius_km).destination(center, 0)
    south = distance(kilometers=radius_km).destination(center, 180)
    east = distance(kilometers=radius_km).destination(center, 90)
    west = distance(kilometers=radius_km).destination(center, 270)

    return south.latitude, west.longitude, north.latitude, east.longitude
