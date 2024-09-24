from pydantic import BaseModel, Field
from typing import List


class Landmark(BaseModel):
    name: str
    type: str
    latitude: float
    longitude: float


class LandmarkQueryResponse(BaseModel):
    landmarks: List[Landmark] = Field(default_factory=list)
    