import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var rememberMe: Bool = false

    var body: some View {
        if isLoggedIn {
            LobbyView()
        } else {
            ZStack {
                // Background with calming health colors
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.2), Color.teal.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    // Logo and App Name
                    VStack {
                        HStack(spacing: 10) {
                            // Syringe for insulin
                            Image(systemName: "syringe")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)

                            // Fork/Carb for food intake
                            Image(systemName: "fork.knife")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)

                            // Drop for glucose
                            Image(systemName: "drop.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                        }

                        Text("Insulocarb")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                    }

                    // Welcome Text
                    VStack(spacing: 8) {
                        Text("Let’s get started")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)

                        Text("Good to see you back!")
                            .font(.body)
                            .foregroundColor(.gray)
                    }

           
                    // Input Fields
                    VStack(spacing: 15) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 30)

                    // Remember Me Toggle
                    HStack {
                        Toggle("Remember me next time", isOn: $rememberMe)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    }
                    .padding(.horizontal, 30)

                    // Login Button
                    Button(action: {
                        isLoggedIn = true // Navigate to ContentView
                    }) {
                        Text("SIGN IN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green)
                            .cornerRadius(10)
                            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 30)

                    // Sign-Up Prompt
               
                }
                .padding(.top, 20)
            }
        }
    }
}
