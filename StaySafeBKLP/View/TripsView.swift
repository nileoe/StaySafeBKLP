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
            arrivalLocationId: 8,
            arrivalLocationName: "Surbiton Station",
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
//            departureTime: Date(),
            arrivalLocationId: 11,
            arrivalLocationName: "Amina's",
//            arrivalTime: Date(),
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
            VStack(alignment: .leading, spacing: 10) {
                Text(trip.title)
                    .font(.headline)
                Text(trip.description)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Departure:")
                            .font(.caption)
                            .bold()
                        Text(trip.departureLocationName)
                            .font(.caption)
                        if let departureTime = trip.departureTime {
                            Text(departureTime, style: .date)
                                .font(.caption)
                        } else {
                            Text("No arrival date recorded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Arrival:")
                            .font(.caption)
                            .bold()
                        Text(trip.arrivalLocationName)
                            .font(.caption)
                        if let arrivalTime = trip.arrivalTime {
                            Text(arrivalTime, style: .date)
                                .font(.caption)
                        } else {
                            Text("No arrival date recorded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Text("Status: \(trip.statusName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }

#Preview {
    TripsView()
}
