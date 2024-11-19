import SwiftUI
import MapKit

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var markerLocation: CLLocationCoordinate2D

    var body: some View {
        ZStack {
            // Full Map with Zoom and Marker Support
            Map(coordinateRegion: $region, annotationItems: [MapMarker(coordinate: markerLocation)]) { marker in
                MapAnnotation(coordinate: marker.coordinate) {
                    DraggablePin(markerLocation: $markerLocation)
                }
            }
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
