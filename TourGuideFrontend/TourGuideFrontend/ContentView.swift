import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject private var locationManager: LocationManager
    @State private var aiResponse: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(locationManager: LocationManager = LocationManager()) {
        _locationManager = StateObject(wrappedValue: locationManager)
    }
    
    
    var body: some View {
        VStack(spacing: 20) {
            if let location = locationManager.userLocation {
                var region: MKCoordinateRegion {
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )
                }
                Text("Tour Guide:")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                
                Text("The Ultimate Tour Guide")
                    .font(.subheadline)
                    .padding(.bottom)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                
                Text("Location: \(location.latitude), \(location.longitude)")
                    .font(.headline)
                    .padding()
                
                Map(initialPosition: .region(region))
                
                Button(action: {
                    sendLocationToBackend(location: location)
                }) {
                    Text(isLoading ? "Loading..." : "Send Location to AI")
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                
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
                }
                
            } else if locationManager.permissionDenied {
                Text("Location Permission Denied.")
                    .foregroundColor(.red)
                    .font(.headline)
                
            } else {
                Text("Requesting Location...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        Spacer()
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

#Preview {
    // Use a mock location manager for the preview
    ContentView(locationManager: MockLocationManager())
}

class MockLocationManager: LocationManager {
    override init() {
        super.init()
        self.userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Mocked San Francisco coordinates
    }
}
