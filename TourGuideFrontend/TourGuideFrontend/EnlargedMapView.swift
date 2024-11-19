import SwiftUI
import MapKit

struct EnlargedMapView: View {
    let location: CLLocationCoordinate2D
    
    var body: some View {
        ZStack {
            MapView(location: location)
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
