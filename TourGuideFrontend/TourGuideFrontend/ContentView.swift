import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var locationManager: LocationManager
    @State private var aiResponse: [Location] = [] // API response model
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isMapExpanded = false
    @State private var region: MKCoordinateRegion
    @State private var markerLocation: LocationItem
    @State private var navigateToLocationsView = false
    
    init(locationManager: LocationManager = LocationManager()) {
        _locationManager = StateObject(wrappedValue: locationManager)
        let initialLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        _region = State(initialValue: MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _markerLocation = State(initialValue: LocationItem(coordinate: initialLocation))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let userLocation = locationManager.userLocation {
                    TourGuideHeader()

                    LocationDetailsView(location: markerLocation.coordinate)

                    MapView(region: $region, markerLocation: $markerLocation)
                        .frame(height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onTapGesture { isMapExpanded = true }
                        .sheet(isPresented: $isMapExpanded) {
                            EnlargedMapView(region: $region, markerLocation: $markerLocation)
                        }

                    Button(action: {
                        sendLocationToBackend(location: markerLocation.coordinate)
                    }) {
                        Text(isLoading ? "Loading..." : "Send Location to AI")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isLoading ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isLoading)

                    NavigationLink(destination: LocationsView(locations: aiResponse), isActive: $navigateToLocationsView) {
                        EmptyView()
                    }
                } else {
                    LocationPermissionView(permissionDenied: locationManager.permissionDenied)
                }

                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }
            }
            .padding()
        }
    }

    func sendLocationToBackend(location: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "http://127.0.0.1:8000/api/location") else {
            errorMessage = "Invalid URL"
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Use POST to send the JSON body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Construct the JSON body
        let body: [String: Any] = [
            "lat": location.latitude,
            "lon": location.longitude,
            "radius": 1.0 // Match the curl request radius
        ]

        // Serialize the body to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        } catch {
            errorMessage = "Failed to encode request body"
            return
        }

        // Perform the network task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received from server"
                }
                return
            }

            // Log the server response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }

            // Decode the response
            do {
                let response = try JSONDecoder().decode(LocationResponse.self, from: data)
                DispatchQueue.main.async {
                    aiResponse = response.locations
                    navigateToLocationsView = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }

        task.resume()
    }


}





// MARK: - Subviews

struct TourGuideHeader: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Tour Guide:")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("The Ultimate Tour Guide")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.bottom)
    }
}

struct LocationDetailsView: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Location Details")
                .font(.headline)
                .foregroundColor(.black)
            
            Text("Latitude: \(location.latitude)")
            Text("Longitude: \(location.longitude)")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(radius: 3)
    }
}

struct ActionButton: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isLoading ? "Loading..." : "Send Location to AI")
                .padding()
                .frame(maxWidth: .infinity)
                .background(isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}

struct ResponseListView: View {
    let aiResponse: [String]
    let errorMessage: String?
    
    var body: some View {
        if !aiResponse.isEmpty {
            List(aiResponse, id: \.self) { item in
                Text(item)
            }
            .listStyle(PlainListStyle())
        }
        
        if let error = errorMessage {
            Text("Error: \(error)")
                .foregroundColor(.red)
                .font(.subheadline)
                .padding()
        }
    }
}

struct LocationPermissionView: View {
    let permissionDenied: Bool
    
    var body: some View {
        if permissionDenied {
            Text("Location Permission Denied.")
                .foregroundColor(.red)
                .font(.headline)
                .padding()
        } else {
            Text("Requesting Location...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
        }
    }
}

struct LocationResponse: Codable {
    let locations: [Location]
}


// MARK: - Preview

#Preview {
    ContentView(locationManager: MockLocationManager())
}

class MockLocationManager: LocationManager {
    override init() {
        super.init()
        self.userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Mocked San Francisco coordinates
    }
}
