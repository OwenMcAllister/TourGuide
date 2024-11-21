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
    }

    @Environment(\.dismiss) var dismiss
}
