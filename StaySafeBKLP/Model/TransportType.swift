import Foundation
import MapKit

enum TransportType: String, CaseIterable, Identifiable {
    case car = "Car"
    case walking = "Walking"
    case transit = "Transit"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .car: return "car.fill"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        }
    }

    var mapKitType: MKDirectionsTransportType {
        switch self {
        case .car: return .automobile
        case .walking: return .walking
        case .transit: return .transit
        }
    }

    init(mapKitType: MKDirectionsTransportType) {
        switch mapKitType {
        case .walking:
            self = .walking
        case .transit:
            self = .transit
        case .automobile:
            self = .car
        default:
            self = .car
        }
    }

    static func fromDescription(_ description: String) -> TransportType {
        let lowercased = description.lowercased()
        if lowercased.contains("car") || lowercased.contains("driving") {
            return .car
        } else if lowercased.contains("walk") {
            return .walking
        } else if lowercased.contains("transit") || lowercased.contains("bus") {
            return .transit
        }
        return .car  // Default
    }
}
