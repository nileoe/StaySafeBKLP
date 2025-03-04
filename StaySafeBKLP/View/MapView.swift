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
    
    private func setInitialUserLocation(_ location: CLLocationCoordinate2D?) {
        if !initialLocationSet, let userLocation = location {
            region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            followUser = true
            initialLocationSet = true
        }
    }

    @State private var followUser = false  // Controls whether to track the user
    @State private var initialLocationSet = false

    var body: some View {
        NavigationStack {
            ZStack {
                UIKitMapView(region: $region, followUser: $followUser)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    // Recenter button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            if let userLocation = locationManager.userLocation {
                                region = MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                                followUser = true
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.trailing, 20)
                }
            }
            .navigationTitle("Map")
            .onReceive(locationManager.$userLocation) { location in
                setInitialUserLocation(location)
            }
            .onAppear {
                setInitialUserLocation(locationManager.userLocation)
            }
        }
    }
}

#Preview {
    MapView()
}
