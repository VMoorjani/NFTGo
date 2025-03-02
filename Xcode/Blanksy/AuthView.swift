//
//  AuthView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import SwiftUI

struct AuthView: View {
    @State private var isLogin = true
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isProcessing = false
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationView {
            VStack (spacing: 0) {
                Picker("", selection: $isLogin) {
                    Text("Log In").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                VStack (spacing: nil) {
                    VStack {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        if !isLogin {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                    }
                    .frame(height: 200)
                    
                    VStack {
                        Button(action: {
                            authenticate()
                        }) {
                            Text(isLogin ? "Log In" : "Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        } else {
                            Text("")
                        }
                    }
                    .frame(height: 100)
                    
                    NavigationLink(destination: ContentView(), isActive: $isAuthenticated) {
                        EmptyView()
                    }
                }
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        }
    }
    
    func authenticate() {
        print("Authenticate called")
        isProcessing = true
        errorMessage = nil
    
        if (username == "") {
            errorMessage = "Username cannot be blank"
            return
        }
        
        if (password == "") {
            errorMessage = "Password cannot be blank"
            return
        }
        
        if (!isLogin && password != confirmPassword) {
            errorMessage = "Passwords do not match"
            return
        }
        
        if isLogin {
                AuthenticationManager.shared.logIn(username: username, password: password) { result in
                    isProcessing = false
                    switch result {
                    case .success():
                        print("Logged in")
                        isAuthenticated = true
                    case .failure(let error):
                        if let networkError = error as? NetworkError {
                            switch networkError {
                            case .invalidURL, .noData:
                                errorMessage = "A network error occurred. Please try again."
                            case .apiError(let message):
                                errorMessage = message
                            }
                        } else {
                            print(error.localizedDescription)
                            errorMessage = "Something went wrong :("
                        }
                    }
                }
            } else {
                AuthenticationManager.shared.signUp(username: username, password: password) { result in
                    isProcessing = false
                    switch result {
                    case .success():
                        print("Signed up")
                        isAuthenticated = true
                    case .failure(let error):
                        if let networkError = error as? NetworkError {
                            switch networkError {
                            case .invalidURL, .noData:
                                errorMessage = "A network error occurred. Please try again."
                            case .apiError(let message):
                                errorMessage = message
                            }
                        } else {
                            print(error.localizedDescription)
                            errorMessage = "Something went wrong :("
                        }
                    }
                }
            }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AuthView()
}
