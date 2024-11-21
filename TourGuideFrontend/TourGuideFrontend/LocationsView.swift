import SwiftUI

struct LocationsView: View {
    // Mock data for demonstration
    let locations: [Location] = [
        Location(name: "Golden Gate Bridge", latitude: 37.8199, longitude: -122.4783, description: "A famous suspension bridge."),
        Location(name: "Alcatraz Island", latitude: 37.8267, longitude: -122.4230, description: "A historic prison island."),
        Location(name: "Coit Tower", latitude: 37.8024, longitude: -122.4058, description: "A landmark tower with stunning views.")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Nearby Noteworthy Locations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                List(locations, id: \.name) { location in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(location.name)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Text("Latitude: \(location.latitude, specifier: "%.4f")")
                            Text("Longitude: \(location.longitude, specifier: "%.4f")")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        
                        Text(location.description)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationBarTitle("Locations", displayMode: .inline)
        }
    }
}


// Preview
struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}
