# built in
from typing import List, Optional
from datetime import datetime

# internal
from src.api.models import LocationResponse, LocationQuery
from src.api.bounding_box import get_bounding_box
from src.api.overpass_client import get_locations_from_overpass
from src.api.openai_client import prepare_openai_prompt, get_noteworthy_locations_from_llm

# external
from fastapi import FastAPI, Depends


def setup_routes(app: FastAPI):
    @app.get("/api/location")
    async def fetch_locations(message: str) -> LocationResponse:
        
        bbox = get_bounding_box(lat, lon, radius_miles)
        locations = get_locations_from_overpass(overpass_query)

        location_response = LocationResponse(locations=locations)

        prompt = prepare_openai_prompt(location_response.locations)
        noteworthy_locations = get_noteworthy_locations_from_llm(prompt)

        return noteworthy_locations