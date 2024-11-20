import SwiftUI
import MapKit

struct DraggablePin: View {
    @Binding var markerLocation: CLLocationCoordinate2D
    @Binding var region: MKCoordinateRegion

    @State private var dragOffset: CGSize = .zero

    var body: some View {
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
                    let mapWidth = UIScreen.main.bounds.width
                    let mapHeight = 300.0 // Match the height of your MapView
                    let latitudeDelta = region.span.latitudeDelta
                    let longitudeDelta = region.span.longitudeDelta

                    let deltaLat = -Double(gesture.translation.height / mapHeight) * latitudeDelta
                    let deltaLon = Double(gesture.translation.width / mapWidth) * longitudeDelta

                    markerLocation.latitude += deltaLat
                    markerLocation.longitude += deltaLon

                    dragOffset = .zero
                    region.center = markerLocation
                }
        )
    }
}
