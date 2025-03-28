import SwiftUI

struct GradientActionButton: View {
    let title: String
    let systemImage: String?
    let baseColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            baseColor,
                            baseColor.opacity(0.6),
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: baseColor.opacity(0.4), radius: 3, x: 0, y: 2)
        }
        .padding(.horizontal, 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        GradientActionButton(
            title: "Pause Trip",
            systemImage: "pause.circle.fill",
            baseColor: .orange,
            action: {}
        )

        GradientActionButton(
            title: "Resume Trip",
            systemImage: "play.circle.fill",
            baseColor: .blue,
            action: {}
        )

        GradientActionButton(
            title: "End Trip",
            systemImage: "xmark.circle.fill",
            baseColor: .red,
            action: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
