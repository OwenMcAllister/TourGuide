#Pydantic Model

from pydantic import BaseModel, Field
from typing import List, Optional

class Location(BaseModel):
    name: Optional[str] = Field(None, description="Name of the location")
    lat: float = Field(..., description="Latitude of the location")
    lon: float = Field(..., description="Longitude of the location")
    tags: Optional[dict] = Field({}, description="Additional tags from OSM")

class LocationResponse(BaseModel):
    locations: List[Location] = Field(..., description="List of location nodes")
