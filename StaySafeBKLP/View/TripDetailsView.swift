import CoreLocation
import MapKit
import SwiftUI

struct TripDetailsView: View {
    let trip: TripDetails
    let onEndTrip: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                        Text(trip.destinationName)
                    }

                    HStack {
                        Image(systemName: "clock")
                        Text("Departure: \(trip.departureTime, style: .time)")
                    }

                    if let arrival = trip.estimatedArrivalTime {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text("Estimated arrival: \(arrival, style: .time)")
                        }
                    }
                }

                Section {
                    Button(action: {
                        onEndTrip()
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("End Trip")
                                .foregroundColor(.red)
                            Spacer()
                        }
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
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleTrip = TripDetails(
        destination: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        destinationName: "London Eye",
        transportType: .walking,
        departureTime: Date(),
        estimatedArrivalTime: Date().addingTimeInterval(3600)  // 1 hour from now
    )

    TripDetailsView(
        trip: sampleTrip,
        onEndTrip: { print("Trip ended") }
    )
}
