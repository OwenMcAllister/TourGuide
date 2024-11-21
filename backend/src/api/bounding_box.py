# external
import geopy

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

    north = geopy.distance.distance(kilometers=radius_km).destination(center, 0)
    south = geopy.distance.distance(kilometers=radius_km).destination(center, 180)
    east = geopy.distance.distance(kilometers=radius_km).destination(center, 90)
    west = geopy.distance.distance(kilometers=radius_km).destination(center, 270)

    return south[0], west[1], north[0], east[1]