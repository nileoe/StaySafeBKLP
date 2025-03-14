import MapKit
import SwiftUI

struct UIKitMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var followUser: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if followUser {
            uiView.setRegion(region, animated: true)
            followUser = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView

        init(_ parent: UIKitMapView) {
            self.parent = parent
        }
    }
}

// MARK: - Preview
struct UIKitMapView_Previews: PreviewProvider {
    static var previews: some View {
        // Default London region for preview
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        UIKitMapView(
            region: .constant(region),
            followUser: .constant(false)
        )
        .frame(height: 300)
        .previewDisplayName("UIKit Map View")
        .background(Color.gray.opacity(0.1))
    }
}
