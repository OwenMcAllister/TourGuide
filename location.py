import math
import openai
from pydantic import BaseModel


class Location(BaseModel):
    latitude: float
    longitude: float
    name: str
    tag: str
    info: str = ""

    def get_latitude(self):
        return self.latitude

    def get_longitude(self):
        return self.longitude

    def get_name(self):
        return self.name

    def get_tag(self):
        return self.tag

    def get_info(self):
        return self.info

    def set_info(self, info: str):
        self.info = info

    def get_bearing(self, node2: 'Location') -> float:
        # Convert to radians
        lat1 = math.radians(self.get_latitude())
        lon1 = math.radians(self.get_longitude())
        lat2 = math.radians(node2.get_latitude())
        lon2 = math.radians(node2.get_longitude())

        delta_lon = lon2 - lon1

        # Calculate the bearing
        x = math.sin(delta_lon) * math.cos(lat2)
        y = math.cos(lat1) * math.sin(lat2) - (math.sin(lat1) * math.cos(lat2) * math.cos(delta_lon))

        initial_bearing = math.atan2(x, y)

        # Convert back to degrees
        initial_bearing = math.degrees(initial_bearing)

        # Normalize the bearing
        compass_bearing = (initial_bearing + 360) % 360

        return compass_bearing

    def fetch_openai_info(self):
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": "Be precise and concise."
                },
                {
                    "role": "user",
                    "content": f"Provide a brief description of the landmark {self.name}."
                }
            ],
            max_tokens=100,
            temperature=0.2
        )

        self.set_info(response.choices[0].message['content'])
