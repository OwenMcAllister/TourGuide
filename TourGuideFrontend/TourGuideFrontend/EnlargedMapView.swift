import SwiftUI
import MapKit

struct EnlargedMapView: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        ZStack {
            // Fullscreen map
            Map(coordinateRegion: .constant(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            ))
            .ignoresSafeArea() // Ensure the map fills the entire view
            
            // Top close button overlay
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
                    }
                }
                .padding(.top, 10) // Add spacing for safe area at the top
                .background(Color.white.opacity(0.8)) // Add a white background for contrast
                Spacer()
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss
}
