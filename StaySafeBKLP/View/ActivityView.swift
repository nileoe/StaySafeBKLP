import SwiftUI


struct ActivityView: View {
    @State var activity: Activity
    let viewTitle: String
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text(activity.activityName)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        Text(activity.activityDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "flag")
                                .foregroundColor(statusColor(for: activity.activityStatusID))
                            Text("Status: \(statusDescription(for: activity.activityStatusID))")
                                .font(.subheadline)
                                .foregroundColor(statusColor(for: activity.activityStatusID))
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Timeline Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.orange)
                            Text("Trip Timeline")
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 24) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                
                                Image(systemName: "arrow.down")
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.green)
                            }
                            
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Departure")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(activity.activityFromName ?? "Unknown location")
                                        .font(.body)
                                    Text(DateFormattingUtility.formatISOString(activity.activityLeave))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Arrival")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(activity.activityToName ?? "Unknown location")
                                        .font(.body)
                                    Text(DateFormattingUtility.formatISOString(activity.activityArrive))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func statusColor(for statusID: Int) -> Color {
        switch statusID {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }

    private func statusDescription(for statusID: Int) -> String {
        switch statusID {
        case 1: return "Active"
        case 2: return "Pending"
        case 3: return "Cancelled"
        default: return "Unknown"
        }
    }}

#Preview {
    ActivityView(
        activity: (Activity(
            activityID: 1,
            activityName: "Morning Hike",
            activityUserID: 101,
            activityUsername: "JohnDoe",
            activityDescription: "A refreshing morning hike through the countryside.",
            activityFromID: 201,
            activityFromName: "Lower Bullington",
            activityLeave: "2025-03-22T08:00:00Z",
            activityToID: 202,
            activityToName: "Highfield Hill",
            activityArrive: "2025-03-22T10:00:00Z",
            activityStatusID: 3,
            activityStatusName: "Planned"
        )),
        viewTitle: "Trip Details"
   )
}

