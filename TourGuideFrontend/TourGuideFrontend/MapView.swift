import SwiftUI
import MapKit


struct MapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var markerLocation: LocationItem

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: [markerLocation]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    DraggablePin(markerLocation: $markerLocation.coordinate, region: $region)
                }
            }
            .cornerRadius(10)
            .shadow(radius: 5)

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
    }

    private func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    private func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }
}
