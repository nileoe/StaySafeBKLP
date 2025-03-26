import CoreLocation
import MapKit
import SwiftUI

struct TripDetailsView: View {
    let activity: Activity
    let onEndTrip: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isEndingTrip = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SectionRow(imageName: "mappin.and.ellipse", imageColor: .red, rowText: activity.activityToName ?? "Destination")
                    SectionRow(imageName: "clock", rowText: "Departure: \(DateFormattingUtility.formatISOString(activity.activityLeave, style: DateFormattingUtility.timeOnly))")
                    SectionRow(imageName: "flag.checkered", rowText: "Estimated arrival: \(DateFormattingUtility.formatISOString(activity.activityArrive, style: DateFormattingUtility.timeOnly))")
                }

                Section {
                    if isEndingTrip {
                        HStack {
                            Spacer()
                            ProgressView("Ending trip...")
                            Spacer()
                        }
                    } else {
                        Button(action: cancelTrip) {
                            HStack {
                                Spacer()
                                Text("End Trip")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Trip Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .disabled(isEndingTrip)
        }
    }

    private func cancelTrip() {
        isEndingTrip = true
        errorMessage = nil

        // Update the activity status to Cancelled using the enum
        Task {
            do {
                let api = StaySafeAPIService()

                var updatedActivity = activity
                updatedActivity.activityStatusID = ActivityStatus.cancelled.rawValue
                updatedActivity.activityStatusName = ActivityStatus.cancelled.name

                // Save the updated activity
                _ = try await api.updateActivity(activity: updatedActivity)

                // Update UI on the main thread
                await MainActor.run {
                    isEndingTrip = false
                    // Call the onEndTrip closure to update the UI
                    onEndTrip()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isEndingTrip = false
                    errorMessage = "Failed to end trip: \(error.localizedDescription)"
                    print("Error cancelling trip: \(error)")
                }
            }
        }
    }
}
struct SectionRow: View {
    let imageName: String
    let imageColor: Color
    let rowText: String
    
    init(imageName: String, imageColor: Color = .black, rowText: String) {
            self.imageName = imageName
            self.imageColor = imageColor
            self.rowText = rowText
        }
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(imageColor)
            Text(rowText)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleActivity = Activity(
        activityID: 123,
        activityName: "Walking to London Eye",
        activityUserID: 1,
        activityDescription: "Walking trip",
        activityFromID: 1,
        activityFromName: "Home",
        activityLeave: "2023-12-01T12:00:00Z",
        activityToID: 2,
        activityToName: "London Eye",
        activityArrive: "2023-12-01T13:00:00Z",
        activityStatusID: 2,
        activityStatusName: "In Progress"
    )

    TripDetailsView(
        activity: sampleActivity,
        onEndTrip: { print("Trip ended") }
    )
}

