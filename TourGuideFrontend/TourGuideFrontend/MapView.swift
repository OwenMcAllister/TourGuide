import SwiftUI
import MapKit

struct MapView: View {
    @State private var region: MKCoordinateRegion
    let location: CLLocationCoordinate2D
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
        _region = State(initialValue: MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack {
            // Full Map with Zoom Support
            Map(coordinateRegion: $region)
                .cornerRadius(10)
                .shadow(radius: 5)
            
            // Zoom Controls
            VStack {
                Spacer()
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
    
    // Zoom In Function
    private func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(region.span.latitudeDelta / 2, 0.002),
            longitudeDelta: max(region.span.longitudeDelta / 2, 0.002)
        )
        region.span = newSpan
    }
    
    // Zoom Out Function
    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(region.span.latitudeDelta * 2, 100),
            longitudeDelta: min(region.span.longitudeDelta * 2, 100)
        )
        region.span = newSpan
    }
}
