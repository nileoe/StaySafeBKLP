import SwiftUI

struct ActivitiesView: View {
    private let apiService = StaySafeAPIService()
    @State private var activities: [Activity] = []
    var body: some View {
        NavigationView {
            List {
                //                ForEach(
                //                    activities, id: \.id) { activity in
                //                        ActivityCard(activity: activity)
                //                            .padding(.vertical, 2)
                //                    }
                //                    .navigationTitle("My Trips")
                ForEach(
                    activities, id: \.id) { activity in
                        NavigationLink(
                            destination: ActivityView(
                                activity: activity,
                                handleConfirm: nil,
                                handleCancel: nil,
                                confirmButtonText: "confirm"
                            ),
                            label: {
                                ActivityCard(activity: activity)
                            }
                        )
                    }
            }
            .task {
                do {
                    activities = try await apiService.getAllActivities()
                    //            } catch TripError.invalidData {
                    //                print("Fetching trips: invalid data")
                    //            } catch TripError.invalidURL {
                    //                print("Fetching trips: invalid url")
                    //            } catch TripError.invalidResponse {
                    //                print("Fetching trips: invalid response")
                } catch {
                    print("unexpected error when fetching activities")
                }
            }
        }
    }
}

struct ActivityCard: View {
    var activity: Activity
    
    private var arrivalTimeString: String {
        let arrivalTime = activity.activityArrive
        guard arrivalTime != "" else {
            return "No arrival time recorded"
        }
        guard let arrivalLocation = activity.activityToName else {
            return "No arrival location recorded"
        }
        guard let arrivalTimeString = formattedDate(arrivalTime) else {
            return "Invalid arrival date string"
        }
        return "Arrival: \(arrivalLocation) at \(arrivalTimeString)"
    }
//    private var departureTimeString: String {
//        if let departureTime = trip.departureTime {
//            return "Departure: \(trip.departureLocationName) at \(formattedDate(departureTime))"
//        } else {
//            return "No departure time recorded"
//       }
//    }
    
    private var departureTimeString: String {
        guard let departureLocation = activity.activityFromName else {
            return "No departure location available"
        }
        guard let departureTimeString = formattedDate(activity.activityLeave) else {
            return "Invalid departure date string"
        }
        return "Departure: \(departureLocation) at \(departureTimeString)"
    }
    
    private var departureIconName: String {
         return "arrow.up.circle.fill"
     }
//    private var departureIconName: String {
//         return trip.departureTime != nil ? "arrow.up.circle.fill" : "questionmark.circle.fill"
//     }
     private var arrivalIconName: String {
         return activity.activityArrive != "" ? "arrow.down.circle.fill" : "questionmark.circle.fill"
     }
    
    private var arrivalIconColor: Color {
        return activity.activityArrive != "" ? .blue: .orange
    }
    private var departureIconColor: Color {
        // TODO remove: assuming emtpy string = no arrival time
        return activity.activityLeave != "" ? .green  : .orange
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(activity.activityName)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(activity.activityDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            HStack {
                Image(systemName: departureIconName)
                    .foregroundColor(departureIconColor)
                Text(departureTimeString)
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            HStack {
                Image(systemName: arrivalIconName)
                    .foregroundColor(arrivalIconColor)
                Text(arrivalTimeString)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            
            Divider()
            
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(
                        statusColor(for: activity.activityStatusName ?? "no status")
                    )
                Text(activity.activityStatusName ?? "no status")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
//        .padding(.horizontal)
    }
    
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }

    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "completed":
            return .green
        case "in progress":
            return .orange
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    ActivitiesView()
}
