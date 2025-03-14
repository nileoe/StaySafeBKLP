import MapKit
import SwiftUI

enum TransportType: String, CaseIterable, Identifiable {
    case car, walking, transit

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
}
