import MapKit
import SwiftUI

struct MapSelectionView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var locationName: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)

        // Clear existing pins
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        // Add pin for selected location
        if let location = selectedLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Destination"
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapSelectionView

        init(_ parent: MapSelectionView) {
            self.parent = parent
        }

        @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.selectedLocation = coordinate
            parent.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )

            // Reverse geocode to get location name
            let location = CLLocation(
                latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let name = [
                        placemark.name,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                    ].compactMap { $0 }.joined(separator: ", ")

                    DispatchQueue.main.async {
                        self.parent.locationName = name
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct MapSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview wrapper to manage state
        PreviewMapSelection()
    }

    private struct PreviewMapSelection: View {
        @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        @State private var selectedLocation: CLLocationCoordinate2D?
        @State private var locationName: String = "Tap to select a location"

        var body: some View {
            VStack {
                MapSelectionView(
                    region: $region,
                    selectedLocation: $selectedLocation,
                    locationName: $locationName
                )
                .frame(height: 300)

                Text("Selected: \(locationName)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
            }
            .previewDisplayName("Map Selection View")
        }
    }
}
