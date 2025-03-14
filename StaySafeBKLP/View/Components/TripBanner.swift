import SwiftUI
import CoreLocation
import MapKit

struct TripBanner: View {
    let trip: TripDetails
    let timeFormatter: DateFormatter
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Trip to \(trip.destinationName)")
                        .font(.headline)
                    
                    if let arrival = trip.estimatedArrivalTime {
                        Text("Arrival: \(arrival, formatter: timeFormatter)")
                            .font(.subheadline)
                    }
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
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    let sampleTrip = TripDetails(
        destination: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        destinationName: "London Eye",
        transportType: .walking,
        departureTime: Date(),
        estimatedArrivalTime: Date().addingTimeInterval(3600) // 1 hour from now
    )

    TripBanner(
        trip: sampleTrip,
        timeFormatter: dateFormatter,
        onTap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
