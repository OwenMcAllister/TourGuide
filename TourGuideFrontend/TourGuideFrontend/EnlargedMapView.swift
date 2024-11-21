import SwiftUI
import MapKit

struct EnlargedMapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var markerLocation: LocationItem

    var body: some View {
        ZStack {
            // Enlarged map view
            Map(coordinateRegion: $region, annotationItems: [markerLocation]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    DraggablePin(markerLocation: $markerLocation.coordinate, region: $region, scaleLatFactor: 17, scaleLongFactor: 9)
                }
            }
            .ignoresSafeArea()

            VStack {
                // Zoom Controls
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

            // Close Button
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
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 10)
                Spacer()
            }
        }
        .onDisappear {
            region.center = markerLocation.coordinate
        }
    }

    // Zoom In/Out Functions
    private func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    private func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }

    @Environment(\.dismiss) var dismiss
}
