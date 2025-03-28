import MapKit
import SwiftUI

struct TrackingMapView: UIViewRepresentable {
    let activity: Activity
    let positions: [Position]
    let showUserLocation: Bool

    // Define polyline identifiers
    private let glowPolylineIdentifier = "GlowPolyline"
    private let mainPolylineIdentifier = "MainPolyline"

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showUserLocation
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Clear previous data (except user location)
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        // Skip if no positions
        guard !positions.isEmpty else { return }

        // Only add start and end annotations
        var annotations = [MKPointAnnotation]()

        // Add start point
        if positions.count > 0 {
            let startPosition = positions[0]
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: startPosition.positionLatitude,
                longitude: startPosition.positionLongitude
            )
            annotation.title = "Start"
            annotations.append(annotation)
        }

        // Add current/end point (if different from start)
        if positions.count > 1 {
            let endPosition = positions.last!
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: endPosition.positionLatitude,
                longitude: endPosition.positionLongitude
            )
            annotation.title = "Latest"
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)

        // Add route polyline if more than one position
        if positions.count > 1 {
            let coordinates = positions.map {
                CLLocationCoordinate2D(
                    latitude: $0.positionLatitude,
                    longitude: $0.positionLongitude
                )
            }

            // Create polylines
            let pointCount = coordinates.count
            let glowPolyline = MKPolyline(coordinates: coordinates, count: pointCount)
            glowPolyline.title = glowPolylineIdentifier

            let mainPolyline = MKPolyline(coordinates: coordinates, count: pointCount)
            mainPolyline.title = mainPolylineIdentifier

            // Add polylines in correct order
            mapView.addOverlay(glowPolyline)
            mapView.addOverlay(mainPolyline)

            // Set region using MKCoordinateRegion
            let region = MKCoordinateRegion(mainPolyline.boundingMapRect)
            mapView.setRegion(region, animated: true)
        } else {
            mapView.setRegion(
                MapRegionUtility.region(
                    center: annotations[0].coordinate,
                    span: MapRegionUtility.defaultZoom
                ),
                animated: true
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(glowIdentifier: glowPolylineIdentifier, mainIdentifier: mainPolylineIdentifier)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let glowIdentifier: String
        let mainIdentifier: String

        init(glowIdentifier: String, mainIdentifier: String) {
            self.glowIdentifier = glowIdentifier
            self.mainIdentifier = mainIdentifier
            super.init()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineCap = .round
            renderer.lineJoin = .round

            if polyline.title == glowIdentifier {
                renderer.strokeColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)  // Light blue
                renderer.lineWidth = 9
            } else if polyline.title == mainIdentifier {
                renderer.strokeColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)  // Apple blue
                renderer.lineWidth = 7
            }

            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            // Configure marker annotation
            let identifier = "PositionMarker"
            let annotationView =
                (mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    as? MKMarkerAnnotationView)
                ?? MKMarkerAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: identifier
                )

            annotationView.canShowCallout = true
            annotationView.annotation = annotation
            annotationView.markerTintColor = annotation.title == "Start" ? .blue : .red

            return annotationView
        }
    }
}
