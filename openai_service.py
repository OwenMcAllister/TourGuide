import openai
from models import Location
from typing import List

# OpenAI API key
openai.api_key = 'your-openai-api-key'

def prepare_openai_prompt(locations: List[Location]) -> str:
    prompt = "Here is a list of locations with details. Return the most noteworthy locations in this format:\n"
    prompt += "Name: <name>\nLatitude: <lat>\nLongitude: <lon>\nReason: <why it's noteworthy>\n\n"

    for location in locations:
        name = location.name if location.name else "Unknown"
        lat = location.lat
        lon = location.lon
        tags = ", ".join([f"{k}: {v}" for k, v in location.tags.items()])

        prompt += f"Name: {name}\nLatitude: {lat}\nLongitude: {lon}\nTags: {tags}\n\n"

    return prompt

def get_noteworthy_locations_from_llm(prompt: str) -> str:
    response = openai.Completion.create(
        model="text-davinci-003",
        prompt=prompt,
        max_tokens=150,
        temperature=0.7
    )
    return response.choices[0].text.strip()