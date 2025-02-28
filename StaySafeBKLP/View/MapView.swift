import SwiftUI
import MapKit
import CoreLocation

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

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        DispatchQueue.main.async {
            self.manager.requestWhenInUseAuthorization()
        }
        
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
        }
        
        // End any running background task to prevent system termination
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startBackgroundTask()
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        default:
            break
        }
    }
    
    private func startBackgroundTask() {
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "LocationUpdate") {
                // Expiration handler
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    // Default region: Kingston University
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.4014, longitude: -0.3046),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var followUser = false  // Controls whether to track the user

    var body: some View {
        NavigationStack {
            UIKitMapView(region: $region, followUser: $followUser)
                .ignoresSafeArea()
                .navigationTitle("Map")
                .onReceive(locationManager.$userLocation) { newLocation in
                    if let newLocation = newLocation {
                        region = MKCoordinateRegion(
                            center: newLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        followUser = true // Enable tracking
                    }
                }
        }
    }
}

#Preview {
    MapView()
}
