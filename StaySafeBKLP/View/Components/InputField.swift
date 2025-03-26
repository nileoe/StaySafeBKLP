import SwiftUI

struct InputField: View {
    @Environment(\.colorScheme) var colorScheme
    var label: String
    var icon: String
    @Binding var text: String
    var isSecure: Bool = false
    var placeholder: String
    var focusedField: FocusState<LoginView.Field?>.Binding
    var field: LoginView.Field

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .padding(.bottom, 2)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                if isSecure {
                    CustomTextField(
                        text: $text,
                        placeholder: placeholder,
                        isSecure: true,
                        textContentType: .password
                    )
                } else {
                    CustomTextField(
                        text: $text,
                        placeholder: placeholder,
                        autocapitalization: .none,
                        textContentType: .username
                    )
                }
            }
            .frame(height: 12)
            .focused(focusedField, equals: field)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
            .shadow(
                color: Color.primary.opacity(colorScheme == .dark ? 0.3 : 0.1),
                radius: 3, x: 0, y: 2
            )
        }
    }
}

// Preview
struct InputField_Previews: PreviewProvider {
    @State private static var dummyText: String = ""
    @FocusState private static var dummyFocusState: LoginView.Field?

    static var previews: some View {
        VStack(spacing: 20) {
            InputField(
                label: "Username",
                icon: "person.fill",
                text: $dummyText,
                placeholder: "Enter your username",
                focusedField: $dummyFocusState,
                field: .username
            )

            InputField(
                label: "Password",
                icon: "lock.fill",
                text: $dummyText,
                isSecure: true,
                placeholder: "Enter your password",
                focusedField: $dummyFocusState,
                field: .password
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
