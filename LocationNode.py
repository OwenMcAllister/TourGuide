import math
import requests
import os
import dotenv

dotenv.load_dotenv('.env')

#Perplexity
KEY = os.getenv('API_KEY')
PERP_URL = "https://api.perplexity.ai/chat/completions"


class Location:

    #Initialize new landmark with lat, long, and result of osm query
    def __init__(self, latitude, longitude, name, tag):
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.tag = tag
        self.info = ""


    #Getter Methods

    def getLatitude(self):
        return self.latitude
    

    def getLongitude(self):
        return self.longitude
    

    def getName(self):
        return self.name
    

    def getTag(self):
        return self.tag
    

    def getInfo(self):
        return self.getInfo
    

    def getBearing(self, node2):

        #Convert to radians
        lat1 = math.radians(self.getLatitude())
        lon1 = math.radians(self.getLongitude())
        lat2 = math.radians(node2.getLatitude())
        lon2 = math.radians(node2.getLongitude())

        delta_lon = lon2 - lon1

        # Calculate the bearing
        x = math.sin(delta_lon) * math.cos(lat2)
        y = math.cos(lat1) * math.sin(lat2) - (math.sin(lat1) * math.cos(lat2) * math.cos(delta_lon))
        
        initial_bearing = math.atan2(x, y)

        #Convert back to degrees
        initial_bearing = math.degrees(initial_bearing)

        #Normalize the bearing
        compass_bearing = (initial_bearing + 360) % 360

        return compass_bearing
    

    #Setter Methods
    def setInfo(self):

        url = "https://api.perplexity.ai/chat/completions"

        payload = {
            "model": "llama-3.1-sonar-small-128k-online",
            "messages": [
                {
                    "role": "system",
                    "content": "Be precise and concise."
                },
                {
                    "role": "user",
                    "content": "How many stars are there in our galaxy?"
                }
            ],
            "max_tokens": "Optional",
            "temperature": 0.2,
            "top_p": 0.9,
            "return_citations": True,
            "search_domain_filter": ["perplexity.ai"],
            "return_images": False,
            "return_related_questions": False,
            "search_recency_filter": "month",
            "top_k": 0,
            "stream": False,
            "presence_penalty": 0,
            "frequency_penalty": 1
        }
        headers = {
            "Authorization": "Bearer KEY",
            "Content-Type": "application/json"
        }

        response = requests.request("POST", url, json=payload, headers=headers)

        print(response.text)