import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userContext: UserContext
    @Environment(\.colorScheme) var colorScheme
    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case username, password
    }

    var body: some View {
        ZStack {
            Color(
                colorScheme == .dark
                    ? Color(UIColor(white: 0.10, alpha: 1.0)) : Color(UIColor.systemGray6)
            )
            .ignoresSafeArea()
            .onTapGesture {
                focusedField = nil
            }

            VStack {
                Spacer()

                // Logo and heading
                StaySafeLogo(size: 60, shadowRadius: 3, shadowOpacity: 0.05)

                Text("StaySafe™")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 50)

                // Login container
                VStack(spacing: 20) {
                    // Username field
                    InputField(
                        label: "Username",
                        icon: "person.fill",
                        text: $username,
                        placeholder: "Enter your username",
                        focusedField: $focusedField,
                        field: .username
                    )

                    // Password field
                    InputField(
                        label: "Password",
                        icon: "lock.fill",
                        text: $password,
                        isSecure: true,
                        placeholder: "Enter your password",
                        focusedField: $focusedField,
                        field: .password
                    )

                    // Error message
                    if let error = userContext.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 10)
                    }

                    // Login button
                    Button(action: login) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.headline)
                            .shadow(
                                color: Color.primary.opacity(colorScheme == .dark ? 0.3 : 0.1),
                                radius: 3, x: 0, y: 2
                            )
                    }
                    .padding(.top, 5)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(
                    color: Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.2),
                    radius: 7, x: 0, y: 4
                )
                .padding(.horizontal, 30)

                Spacer()

                Spacer()

                // Footer text
                Text("Stay Connected. Stay Safe.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .onSubmit {
                switch focusedField {
                case .username:
                    focusedField = .password
                case .password:
                    login()
                case .none:
                    break
                }
            }
        }
    }

    private func login() {
        guard !username.isEmpty else { return }
        userContext.login(username: username)
    }
}

#Preview {
    LoginView()
        .environmentObject(UserContext())
}
