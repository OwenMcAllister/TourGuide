import SwiftUI
import MapKit

struct MapView: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(
            MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        ))
        .frame(height: 300)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.vertical)
    }
}

#Preview {
    MapView(location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
}
