# built-in
from typing import List, Optional

# internal
from src.api.models import Location, LocationResponse
from src.globals.environment import Environment

# external
from openai import AsyncOpenAI
from dotenv import load_dotenv
import json
from pydantic import ValidationError

load_dotenv()
environment = Environment()
client = AsyncOpenAI()
client.api_key = environment.OPENAI_API_KEY

async def process_overpass_data(overpass_dump: str) -> LocationResponse:
    """
    Sends the Overpass dump to OpenAI API and processes the response into a structured output.
    """
    response = await client.beta.chat.completions.parse(
        model="gpt-4o-mini-2024-07-18",
        messages=[
            {
                "role": "system",
                "content": "Extract the 10 most noteworth nodes from this list of data, and extract the information about them. Generate a description for each location."
            },
            {
                "role": "user",
                "content": f"Process this Overpass data into structured output:\n\n{overpass_dump}"
            }
        ],
        response_format=LocationResponse,
        temperature=0,
    )

    structured_data = response.choices[0].message.content

    try:
        data = json.loads(structured_data)
    except json.JSONDecodeError as e:
        raise ValueError(f"Failed to decode JSON: {e}")

    if 'locations' not in data:
        raise ValueError("The key 'locations' is missing from the response data.")

    valid_locations = []
    for item in data['locations']:
        try:
            location = Location.parse_obj(item)
            valid_locations.append(location)
        except ValidationError as e:
            print(f"Skipping invalid entry: {e}")

    return LocationResponse(locations=valid_locations)
