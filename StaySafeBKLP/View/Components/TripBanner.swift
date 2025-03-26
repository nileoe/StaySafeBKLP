import SwiftUI
import CoreLocation
import MapKit

struct TripBanner: View {
    let activity: Activity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(activity.activityName)
                        .font(.headline)

                    Text(
                        "Arrival: \(DateFormattingUtility.formatISOString(activity.activityArrive, style: DateFormattingUtility.timeOnly))"
                    )
                }
                .padding(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    let sampleTrip = Activity(
        activityID: 1,
        activityName: "Trip to London Eye",
        activityUserID: 1,
        activityDescription: "Sightseeing trip",
        activityFromID: 1,
        activityLeave: "2025-03-25T07:33:21.000Z",
        activityToID: 2,
        activityArrive: "2025-03-25T07:43:45.000Z",
        activityStatusID: 1
    )

    TripBanner(
        activity: sampleTrip,
        onTap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
