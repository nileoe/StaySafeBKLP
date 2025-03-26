import SwiftUI

struct DepartureSection: View {
    @Binding var departureDate: Date
    @State private var isValid: Bool = true
    @State private var validationMessage: String = ""
    var onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Departure")
                .font(.subheadline)
                .foregroundColor(.secondary)

            DatePicker(
                "", selection: $departureDate, displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .onChange(of: departureDate) { _, _ in
                validateDepartureTime()
                onChange()
            }

            if !isValid {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private func validateDepartureTime() {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)  // Add 1-minute buffer

        if departureDate < oneMinuteAgo {
            isValid = false
            validationMessage = "Departure time cannot be in the past."
        } else {
            isValid = true
            validationMessage = ""
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

                Text("Selected: \(departureDate, formatter: DateFormattingUtility.shortDateTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
