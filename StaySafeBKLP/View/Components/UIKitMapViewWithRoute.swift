import MapKit
import SwiftUI

struct UIKitMapViewWithRoute: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var followUser: Bool
    let route: MKRoute
    let destination: CLLocationCoordinate2D

    // Define identifiers for the polylines
    private let glowPolylineIdentifier = "GlowPolyline"
    private let mainPolylineIdentifier = "MainPolyline"

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

        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)

        // Get route coordinates from the MKRoute's polyline
        let pointCount = route.polyline.pointCount
        let routeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(
            capacity: pointCount)
        route.polyline.getCoordinates(
            routeCoordinates, range: NSRange(location: 0, length: pointCount))

        // Create glow polyline
        let glowPolyline = MKPolyline(coordinates: routeCoordinates, count: pointCount)
        glowPolyline.title = glowPolylineIdentifier

        // Create main polyline
        let mainPolyline = MKPolyline(coordinates: routeCoordinates, count: pointCount)
        mainPolyline.title = mainPolylineIdentifier

        // Add polylines in correct order (glow first, then main)
        mapView.addOverlay(glowPolyline)
        mapView.addOverlay(mainPolyline)

        // Free memory
        routeCoordinates.deallocate()

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
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineCap = .round
            renderer.lineJoin = .round

            if polyline.title == parent.glowPolylineIdentifier {
                renderer.strokeColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)  // Light blue
                renderer.lineWidth = 9
            } else if polyline.title == parent.mainPolylineIdentifier {
                renderer.strokeColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)  // Apple blue
                renderer.lineWidth = 7
            }

            return renderer
        }
    }
}

// MARK: - Preview
struct UIKitMapViewWithRoute_Previews: PreviewProvider {
    static var previews: some View {
        PreviewMapWithRoute()
    }

    private struct PreviewMapWithRoute: View {
        @State private var region = MapRegionUtility.region(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
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
                    self.region = MapRegionUtility.regionForRoute(route) ?? self.region
                }
            }
        }
    }
}
