import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var aiResponse: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let location = locationManager.userLocation {
                Text("Location: \(location.latitude), \(location.longitude)")
                    .padding()

                Button(action: {
                    sendLocationToBackend(location: location)
                }) {
                    Text(isLoading ? "Loading..." : "Send Location to AI")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if !aiResponse.isEmpty {
                    List(aiResponse, id: \.self) { item in
                        Text(item)
                    }
                }

                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }

            } else if locationManager.permissionDenied {
                Text("Location Permission Denied.")
                    .foregroundColor(.red)
            } else {
                Text("Requesting Location...")
            }
        }
        .padding()
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
