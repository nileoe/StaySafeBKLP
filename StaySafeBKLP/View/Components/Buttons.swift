import SwiftUI

struct WideRectangleButton: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        WideRectangleIconButton(
            text: text,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            action: action,
            imageName: nil
        )
    }
}
struct WideRectangleIconButton: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    let imageName: String?
    
    init(
        text: String,
        backgroundColor: Color,
        foregroundColor: Color,
        action: @escaping () -> Void,
        imageName: String?
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
        self.imageName = imageName
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .foregroundColor(foregroundColor)
                }
                Text(text)
                    .font(.headline)
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
}
