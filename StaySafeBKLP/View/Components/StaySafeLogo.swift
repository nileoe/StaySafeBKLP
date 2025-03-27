import SwiftUI

struct StaySafeLogo: View {
    @Environment(\.colorScheme) var colorScheme

    var size: CGFloat
    var shadowRadius: CGFloat = 2
    var shadowOpacity: CGFloat = 0.05

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .mask(
            Image(systemName: "shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        )
        .frame(width: size, height: size)
        .shadow(
            color: Color.primary.opacity(colorScheme == .dark ? shadowOpacity * 6 : shadowOpacity),
            radius: shadowRadius,
            x: 0,
            y: shadowRadius / 1.5
        )
    }
}

#Preview("Large Logo") {
    StaySafeLogo(size: 60)
}

#Preview("Small Logo") {
    StaySafeLogo(size: 30)
}

#Preview("Tiny Logo", traits: .sizeThatFitsLayout) {
    StaySafeLogo(size: 20, shadowRadius: 1)
        .padding()
}
