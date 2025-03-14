import SwiftUI

struct DepartureSection: View {
    @Binding var departureDate: Date
    let onChange: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Departure")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                DatePicker(
                    "", selection: $departureDate, displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .onChange(of: departureDate) { _, _ in onChange() }
            }
            Spacer()
        }
    }
}

// MARK: - Preview
struct DepartureSection_Previews: PreviewProvider {
    static var previews: some View {
        PreviewDepartureSection()
            .padding()
            .previewLayout(.sizeThatFits)
    }

    private struct PreviewDepartureSection: View {
        @State private var departureDate = Date()

        var body: some View {
            VStack(spacing: 20) {
                DepartureSection(
                    departureDate: $departureDate,
                    onChange: {
                        print("Date changed to: \(departureDate)")
                    })

                Text("Selected: \(departureDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }

        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }
    }
}
