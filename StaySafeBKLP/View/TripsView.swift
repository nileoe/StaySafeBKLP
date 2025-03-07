import SwiftUI

struct TripsView: View {
    // for the life of me I kept running into errors when trying to supply the trips as an external argument. The data will use the API anyway so this is obviously temporary
    var trips: [Trip] = [
        Trip(
            id: 1,
            title: "Walk home",
            username: "aishaahmed",
            description: "Walk from university to Surbiton train station",
            userId: 1,
            departureLocationId: 10,
            departureLocationName: "Work",
            arrivalLocationId: 8,
            arrivalLocationName: "Surbiton Station",
            statusId: 1,
            statusName: "Planned"
        ),
        Trip(
            id: 2,
            title: "Walk home",
            username: "aishaahmed",
            description: "Walk from university to Surbiton train station",
            userId: 1,
            departureLocationId: 10,
            departureLocationName: "Work",
            departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 5)),
            arrivalLocationId: 8,
            arrivalLocationName: "Surbiton Station",
            arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 5, hour: 18, minute: 0)),
            statusId: 5,
            statusName: "Completed"
        ),
        Trip(
            id: 3,
            title: "Visiting Amina",
            username: "aishaahmed",
            description: "Dinner at Amina's at 7pm",
            userId: 1,
            departureLocationId: 1,
            departureLocationName: "Berrylands Station",
            departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 10)),
            arrivalLocationId: 11,
            arrivalLocationName: "Amina's",
            arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 10, hour: 19, minute: 0)),
            statusId: 5,
            statusName: "Completed"
        )
    ]
    var body: some View {
        NavigationView {
            List {
                ForEach(
                    trips, id: \.id) { trip in
                        TripCard(trip: trip)
                            .padding(.vertical, 5)
                    }
                    .navigationTitle("Trips")
            }
        }
    }
}

struct TripCard: View {
    var trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trip.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(trip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            if let departureTime = trip.departureTime {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                    Text("Departure: \(trip.departureLocationName) at \(formattedDate(departureTime))")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            
            if let arrivalTime = trip.arrivalTime {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                    Text("Arrival: \(trip.arrivalLocationName) at \(formattedDate(arrivalTime))")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(statusColor(for: trip.statusName))
                Text(trip.statusName)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
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
    TripsView()
}
