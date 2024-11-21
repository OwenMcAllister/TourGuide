# built in
from typing import List
from datetime import datetime

# internal
from src.api.models import LocationResponse, LocationQuery
from src.api.overpass_client import get_locations_from_overpass
from src.api.openai_client import process_overpass_data

# external
from fastapi import FastAPI, Depends

def setup_routes(app: FastAPI):
    @app.post("/api/location")
    async def fetch_locations(request: LocationQuery) -> LocationResponse:
        locations: List[Locations] = await get_locations_from_overpass(request.lat, request.lon, request.radius)
        noteworthy_locations = await process_overpass_data(locations)

        return noteworthy_locations
