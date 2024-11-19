import SwiftUI
import MapKit

struct EnlargedMapView: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        VStack {
            Text("Map View")
                .font(.headline)
                .padding(.top)
            
            Map(coordinateRegion: .constant(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            ))
            .ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    // Close the sheet
                    dismiss()
                }
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss // Dismiss environment variable to close the sheet
}
