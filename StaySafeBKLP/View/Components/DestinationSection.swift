import SwiftUI

struct DestinationSection: View {
    let destinationName: String

    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.red)
                .font(.system(size: 22))

            VStack(alignment: .leading) {
                Text("Destination")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(destinationName.isEmpty ? "Tap on map to select" : destinationName)
                    .font(.headline)
                    .foregroundColor(destinationName.isEmpty ? .secondary : .primary)
            }
            Spacer()
        }
    }
}

// MARK: - Preview
struct DestinationSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with a destination
            DestinationSection(destinationName: "London Eye, South Bank, London")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("With Destination")

            // Preview without a destination
            DestinationSection(destinationName: "")
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("No Destination")
        }
    }
}
