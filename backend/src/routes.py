# built in
from typing import List
from datetime import datetime

# internal
from src.api.models import LocationResponse, LocationQuery
from src.api.bounding_box import get_bounding_box
from src.api.overpass_client import get_locations_from_overpass
from src.api.openai_client import prepare_openai_prompt, get_noteworthy_locations_from_llm

# external
from fastapi import FastAPI, Depends

def setup_routes(app: FastAPI):
    @app.get("/api/location", response_model=LocationResponse)
    async def fetch_locations(lat: float, lon: float, radius_miles: float, overpass_query: str) -> LocationResponse:
        bbox = await get_bounding_box(lat, lon, radius_miles)
        locations = await get_locations_from_overpass(overpass_query, bbox)
        
        prompt = prepare_openai_prompt(locations)
        noteworthy_locations = await get_noteworthy_locations_from_llm(prompt)

        return LocationResponse(locations=noteworthy_locations)
