import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared: LocationManager = LocationManager()
    let manager = CLLocationManager()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    @Published var userLocation: CLLocationCoordinate2D?

    override init() {// TODO hack
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

    func locationManager(
        _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
    ) {
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
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
    }
}
