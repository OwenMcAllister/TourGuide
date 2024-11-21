import SwiftUI
import MapKit

struct LocationsView: View {
    // Mock data for demonstration
    let locations: [Location] = [
        Location(name: "Golden Gate Bridge", latitude: 37.8199, longitude: -122.4783, description: "A famous suspension bridge."),
        Location(name: "Alcatraz Island", latitude: 37.8267, longitude: -122.4230, description: "A historic prison island."),
        Location(name: "Coit Tower", latitude: 37.8024, longitude: -122.4058, description: "A landmark tower with stunning views.")
    ]
    
    // State to manage the selected location
    @State private var selectedLocation: Location? = nil
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("Nearby Noteworthy Locations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Map View
                ZStack {
                    Map(coordinateRegion: $region, annotationItems: [selectedLocation].compactMap { $0 }) { location in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.red)
                                .shadow(radius: 5)
                        }
                    }
                    .frame(height: 300) // Adjust map height
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Zoom Controls
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                Button(action: zoomIn) {
                                    Image(systemName: "plus.magnifyingglass")
                                        .font(.title)
                                        .padding()
                                        .background(Circle().fill(Color.white))
                                        .shadow(radius: 5)
                                }
                                Button(action: zoomOut) {
                                    Image(systemName: "minus.magnifyingglass")
                                        .font(.title)
                                        .padding()
                                        .background(Circle().fill(Color.white))
                                        .shadow(radius: 5)
                                }
                            }
                            .padding()
                        }
                    }
                }

                // Location List
                List(locations) { location in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
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
                        .padding(.vertical, 8) // Inner vertical padding for text
                        Spacer() // Ensures alignment and spacing
                    }
                    .padding(.horizontal) // Outer horizontal padding
                    .background(Color.white) // Optional for better visibility
                    .cornerRadius(10)
                    .shadow(radius: 1) // Optional shadow for card effect
                    .onTapGesture {
                        // Update the selected location and map region
                        selectedLocation = location
                        region.center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationBarHidden(true) // Remove navigation bar title
        }
    }
    
    // Zoom In Functionality
    private func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    // Zoom Out Functionality
    private func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }
}

struct Location: Identifiable, Codable {
    let id = UUID() // Unique identifier for each location
    let name: String
    let latitude: Double
    let longitude: Double
    let description: String
}

// Preview
struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}
