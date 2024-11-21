import SwiftUI
import MapKit

struct DraggablePin: View {
    @Binding var markerLocation: CLLocationCoordinate2D
    @Binding var region: MKCoordinateRegion

    // Scale factor to differentiate between normal and enlarged views
    var scaleLatFactor: CGFloat = 1.0
    var scaleLongFactor: CGFloat = 1.0

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.red)
                    .shadow(radius: 3)

                Circle()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color.red.opacity(0.2))
            }
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation
                    }
                    .onEnded { gesture in
                        let mapWidth = geometry.size.width
                        let mapHeight = geometry.size.height

                        // Adjust sensitivity based on scaleFactor
                        let latitudeDelta = region.span.latitudeDelta / Double(scaleLatFactor)
                        let longitudeDelta = region.span.longitudeDelta / Double(scaleLongFactor)

                        let scaleLat = latitudeDelta / mapHeight
                        let scaleLon = longitudeDelta / mapWidth

                        // Calculate latitude and longitude changes
                        let deltaLat = -gesture.translation.height * scaleLat
                        let deltaLon = gesture.translation.width * scaleLon

                        // Update marker location
                        markerLocation.latitude += deltaLat
                        markerLocation.longitude += deltaLon

                        // Reset drag offset
                        dragOffset = .zero

                        // Update map center to reflect the new marker location
                        region.center = markerLocation
                    }
            )
        }
        .frame(width: 44, height: 44) // Ensures proper pin size
    }
}
