import Foundation
import SwiftUI

/// Utility for consistent date formatting
struct DateFormattingUtility {
    // MARK: - ISO8601 Formatters

    /// Standard ISO8601 formatter for API communication
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// ISO8601 formatter with milliseconds for API responses with fractional seconds
    static let iso8601WithMilliseconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    // MARK: - DateFormatters

    /// Time only formatter (e.g., "10:30 AM")
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    /// Short date and time formatter (e.g., "3/25/25, 10:30 AM")
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    /// Medium date and time formatter (e.g., "Mar 25, 2025, 10:30 AM")
    static let mediumDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    // MARK: - Helper Functions

    /// Format an ISO8601 string to a display date/time string
    static func formatISOString(_ isoString: String, style: DateFormatter = mediumDateTime)
        -> String
    {
        print("string input: \(isoString)")
        guard let date = iso8601WithMilliseconds.date(from: isoString) else {
            print("returning unknown time")
            return "Unknown time"
        }
        print("returning \(style.string(from: date))")
        return style.string(from: date)
    }

    /// Format a date for API submission (ISO8601)
    static func formatDateForAPI(_ date: Date) -> String {
        return iso8601.string(from: date)
    }

    /// Returns color for activity status
    static func statusColor(for statusName: String?) -> Color {
        guard let status = statusName?.lowercased() else { return .gray }

        switch status {
        case "completed":
            return .green
        case "started", "in progress":
            return .blue
        case "paused":
            return .orange
        case "cancelled":
            return .red
        case "planned":
            return .purple
        default:
            return .gray
        }
    }
}
