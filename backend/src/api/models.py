# builtin
from typing import List, Optional

# external
from pydantic import BaseModel, Field

class Location(BaseModel):
    name: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    description: Optional[str] = None

class LocationResponse(BaseModel):
    locations: List[Location]

class LocationQuery(BaseModel):
    lat: float
    lon: float
    radius: Optional[float] = 1

