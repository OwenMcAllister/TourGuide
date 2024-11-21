import SwiftUI
import MapKit

struct LocationItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}
