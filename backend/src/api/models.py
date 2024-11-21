# builtin
from typing import List, Optional

# external
from pydantic import BaseModel, Field

class Location(BaseModel):
    name: Optional[str] = Field(None, description="Name of the location")
    lat: Optional[float] = Field(..., description="Latitude of the location")
    lon: Optional[float] = Field(..., description="Longitude of the location")
    tags: Optional[dict] = Field({}, description="Additional tags from OSM")

class LocationResponse(BaseModel):
    locations: List[Location] = Field(..., description="List of location nodes")

class LocationQuery(BaseModel):
    lat: float
    lon: float
    radius: Optional[float] = 1

