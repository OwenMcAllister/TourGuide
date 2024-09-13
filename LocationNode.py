import math

class Location:

    #Initialize new landmark with lat, long, and result of osm query
    def __init__(self, latitude, longitude, name, category, info):
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.category = category
        self.info = info


    def getLatitude(self):
        return self.latitude
    

    def getLongitude(self):
        return self.longitude
    

    def getName(self):
        return self.latitude
    

    def getCategory(self):
        return self.category
    

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