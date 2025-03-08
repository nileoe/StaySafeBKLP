import SwiftUI

struct TripsView: View {
    @State private var trips: [Trip] = []
    var body: some View {
        NavigationView {
            List {
                ForEach(
                    trips, id: \.id) { trip in
                        TripCard(trip: trip)
                            .padding(.vertical, 2)
                    }
                    .navigationTitle("My Trips")
            }
        }
        .task {
            do {
                trips = try await getAllTrips()
            } catch TripError.invalidData {
                print("Fetching trips: invalid data")
            } catch TripError.invalidURL {
                print("Fetching trips: invalid url")
            } catch TripError.invalidResponse {
                print("Fetching trips: invalid response")
            } catch {
                print("unexpected error")
            }
        }
    }
}

struct TripCard: View {
    var trip: Trip
    
    private var arrivalTimeString: String {
        if let arrivalTime = trip.arrivalTime {
            return "Arrival: \(trip.arrivalLocationName) at \(formattedDate(arrivalTime))"
        } else {
            return "No arrival time recorded"
       }
    }
    private var departureTimeString: String {
        if let departureTime = trip.departureTime {
            return "Departure: \(trip.departureLocationName) at \(formattedDate(departureTime))"
        } else {
            return "No departure time recorded"
       }
    }
    
    private var departureIconName: String {
         return trip.departureTime != nil ? "arrow.up.circle.fill" : "questionmark.circle.fill"
     }
     private var arrivalIconName: String {
         return trip.arrivalTime != nil ? "arrow.down.circle.fill" : "questionmark.circle.fill"
     }
    
    private var arrivalIconColor: Color {
        return trip.arrivalTime != nil ? .blue: .orange
    }
    private var departureIconColor: Color {
        return trip.departureTime != nil ? .green  : .orange
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(trip.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(trip.description)
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
//        .padding(.horizontal)
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
