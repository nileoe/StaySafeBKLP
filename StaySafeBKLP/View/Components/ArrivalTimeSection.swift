import SwiftUI

struct ArrivalTimeSection: View {
    let isCalculating: Bool
    let arrivalTime: Date?

    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.blue)
                .font(.system(size: 22))

            VStack(alignment: .leading, spacing: 4) {
                Text("Estimated Arrival")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if isCalculating {
                    HStack(spacing: 8) {
                        Text("Calculating...")
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                } else if let arrivalTime = arrivalTime {
                    Text(arrivalTime, style: .time)
                        .font(.headline)

                    Text(arrivalTime, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Unable to calculate")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Preview
struct ArrivalTimeSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with arrival time
            ArrivalTimeSection(isCalculating: false, arrivalTime: Date().addingTimeInterval(3600))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("With Arrival Time")

            // Preview with calculating state
            ArrivalTimeSection(isCalculating: true, arrivalTime: nil)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Calculating")

            // Preview with error state
            ArrivalTimeSection(isCalculating: false, arrivalTime: nil)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Error")
        }
    }
}
