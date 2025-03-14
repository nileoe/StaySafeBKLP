import SwiftUI

struct TransportSection: View {
    @Binding var transportType: TransportType
    let onChange: () -> Void

    var body: some View {
        HStack {
            Text("Transport")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Picker("Transport", selection: $transportType) {
                ForEach(TransportType.allCases) { type in
                    Label(type.rawValue.capitalized, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: transportType) { _, _ in onChange() }
        }
    }
}

// MARK: - Preview
#Preview {
    // Simple interactive preview
    @Previewable @State var transportType = TransportType.car
    
    return TransportSection(
        transportType: $transportType,
        onChange: { print("Transport changed") }
    )
    .padding()
}
