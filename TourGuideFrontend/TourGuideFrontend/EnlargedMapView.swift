import SwiftUI
import MapKit

struct EnlargedMapView: View {
    let location: CLLocationCoordinate2D
    @State private var region: MKCoordinateRegion
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
        _region = State(initialValue: MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack {
            // Fullscreen map
            Map(coordinateRegion: $region)
                .ignoresSafeArea() // Map fills the entire screen
            
            // Close button and zoom controls overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .padding(.top, 10)
                .background(Color.white.opacity(0.8))
                
                Spacer()
                
                // Zoom controls
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: {
                            zoomIn()
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 5)
                        }
                        Button(action: {
                            zoomOut()
                        }) {
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
    }
    
    @Environment(\.dismiss) var dismiss
    
    // Zoom functions
    private func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(region.span.latitudeDelta / 2, 0.002),
            longitudeDelta: max(region.span.longitudeDelta / 2, 0.002)
        )
        region.span = newSpan
    }
    
    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(region.span.latitudeDelta * 2, 100),
            longitudeDelta: min(region.span.longitudeDelta * 2, 100)
        )
        region.span = newSpan
    }
}
