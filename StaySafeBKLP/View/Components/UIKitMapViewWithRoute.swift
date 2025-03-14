import MapKit
import SwiftUI

struct UIKitMapViewWithRoute: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var followUser: Bool
    let route: MKRoute
    let destination: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if followUser {
            mapView.setRegion(region, animated: true)
            followUser = false
        }

        // Remove existing overlays and add the route
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(route.polyline)

        // Add destination annotation
        let annotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(annotations)

        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destination
        destinationAnnotation.title = "Destination"
        mapView.addAnnotation(destinationAnnotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapViewWithRoute

        init(_ parent: UIKitMapViewWithRoute) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - Preview
struct UIKitMapViewWithRoute_Previews: PreviewProvider {
    static var previews: some View {
        PreviewMapWithRoute()
    }

    private struct PreviewMapWithRoute: View {
        @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        @State private var mockRoute: MKRoute?
        @State private var isLoading = true

        var body: some View {
            ZStack {
                if let route = mockRoute {
                    UIKitMapViewWithRoute(
                        region: $region,
                        followUser: .constant(false),
                        route: route,
                        destination: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
                    )
                } else {
                    Color.gray.opacity(0.3)
                    if isLoading {
                        ProgressView("Creating preview route...")
                    } else {
                        Text("Could not create preview route")
                    }
                }
            }
            .frame(height: 300)
            .background(Color.gray.opacity(0.1))
            .onAppear(perform: createMockRoute)
        }

        private func createMockRoute() {
            let request = MKDirections.Request()
            request.source = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
                ))
            request.destination = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: CLLocationCoordinate2D(latitude: 51.51, longitude: -0.13)
                ))

            MKDirections(request: request).calculate { response, error in
                isLoading = false
                if let route = response?.routes.first {
                    self.mockRoute = route
                    self.region = MKCoordinateRegion(route.polyline.boundingMapRect)
                }
            }
        }
    }
}
