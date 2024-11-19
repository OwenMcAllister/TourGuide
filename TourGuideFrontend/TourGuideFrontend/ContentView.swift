import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var locationManager: LocationManager
    @State private var aiResponse: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isMapExpanded = false // State to control map enlargement
    @State private var region: MKCoordinateRegion // Shared region state
    @State private var markerLocation: CLLocationCoordinate2D // Shared marker location

    init(locationManager: LocationManager = LocationManager()) {
        _locationManager = StateObject(wrappedValue: locationManager)
        let initialLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Default location
        _region = State(initialValue: MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _markerLocation = State(initialValue: initialLocation)
    }

    var body: some View {
        ZStack {
            // Full-screen background
            Color(.systemGray6)
                .ignoresSafeArea()
            
            // Foreground content
            VStack(spacing: 20) {
                if let userLocation = locationManager.userLocation {
                    TourGuideHeader()
                    
                    // Show the updated marker location details
                    LocationDetailsView(location: markerLocation)
                    
                    // Draggable Map View with Tap Gesture for Enlargement
                    MapView(region: $region, markerLocation: $markerLocation)
                        .frame(height: 300) // Fixed height for the map
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onTapGesture {
                            isMapExpanded = true
                        }
                        .sheet(isPresented: $isMapExpanded) {
                            // Pass the shared state to the enlarged map view
                            EnlargedMapView(region: $region, markerLocation: $markerLocation)
                        }
                    
                    // Action Button to Send the Location to the Backend
                    ActionButton(isLoading: isLoading) {
                        sendLocationToBackend(location: markerLocation)
                    }
                    
                    // Display AI Response or Error Message
                    ResponseListView(aiResponse: aiResponse, errorMessage: errorMessage)
                } else {
                    // Handle Missing Permissions or Location Request State
                    LocationPermissionView(permissionDenied: locationManager.permissionDenied)
                }
            }
            .padding()
        }
    }

    func sendLocationToBackend(location: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "APIURL")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    errorMessage = error?.localizedDescription
                }
                return
            }
            
            if let responseList = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    aiResponse = responseList
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Invalid response from server."
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
