//
//  AuthManager.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case apiError(message: String)
}

struct AuthenticationManager {
    static let shared = AuthenticationManager()
    private let baseURL = URL(string: "http://ec2-35-170-185-57.compute-1.amazonaws.com")! 

    private init() { }
    
    func signUp(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "/signup", relativeTo: baseURL) else {
            print("error 1")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "username=\(username)&password=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error 2")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                print("error 3")
                DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
                return
            }
            
            print(data)
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool {
                    if success {
                        print(json)
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.set(json["solana_public_key"], forKey: "publicKey")
                        DispatchQueue.main.async { completion(.success(())) }
                    } else {
                        print("Error 4")
                        let message = json["message"] as? String ?? "Signup failed"
                        DispatchQueue.main.async { completion(.failure(NetworkError.apiError(message: message))) }
                    }
                }
            } catch {
                print("Error 5")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func logIn(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "/login", relativeTo: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "username=\(username)&password=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error 1")
                print(error)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            } else {
                print("Data was empty")
            }
            
            
            guard let data = data else {
                print("Error 2")
                print(error)
                DispatchQueue.main.async { completion(.failure(NetworkError.noData)) }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool {
                    if success {
                        print(json)
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.set(json["solana_public_key"], forKey: "publicKey")
                        DispatchQueue.main.async { completion(.success(())) }
                    } else {
                        print("Error 3")
                        let message = json["message"] as? String ?? "Login failed"
                        DispatchQueue.main.async { completion(.failure(NetworkError.apiError(message: message))) }
                    }
                }
            } catch {
                print("Error 4")
                print(error)
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}



