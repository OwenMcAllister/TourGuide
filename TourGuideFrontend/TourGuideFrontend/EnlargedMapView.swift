import SwiftUI
import MapKit

struct EnlargedMapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var markerLocation: CLLocationCoordinate2D
    
    var body: some View {
        ZStack {
            MapView(region: $region, markerLocation: $markerLocation)
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
                    }
                }
                .padding(.top, 10)
                .background(Color.white.opacity(0.8))
                Spacer()
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss
}
