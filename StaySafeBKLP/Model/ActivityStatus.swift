import Foundation
import SwiftUI

enum ActivityStatus: Int, CaseIterable, Identifiable {
    case planned = 1
    case started = 2
    case paused = 3
    case cancelled = 4
    case completed = 5

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .planned: return "Planned"
        case .started: return "Started"
        case .paused: return "Paused"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        }
    }

    var color: Color {
        switch self {
        case .planned: return .green
        case .started: return .blue
        case .paused: return .orange
        case .cancelled: return .red
        case .completed: return .gray
        }
    }

    var icon: String {
        switch self {
        case .planned: return "calendar"
        case .started: return "figure.walk"
        case .paused: return "pause.circle"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.circle"
        }
    }

    var isActive: Bool {
        self == .started || self == .paused
    }

    var isTerminated: Bool {
        self == .cancelled || self == .completed
    }

    var buttonText: String {
        switch self {
        case .planned: return "Plan Trip"
        case .started: return "Start Trip"
        case .paused: return "Resume Trip"
        case .cancelled: return "Trip Cancelled"
        case .completed: return "Trip Completed"
        }
    }
}
