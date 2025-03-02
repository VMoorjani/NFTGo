//
//  MintNFTView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/2/25.
//

import SwiftUI
import CoreLocation

struct MintNFTView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedImage: UIImage?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @Binding var showMintMenu: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image selection view
                Group {
                    if let image = locationManager.closestPinImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("ERROR LOADING IMAGE")
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(8)
                    }
                }
                
                Text("Name: \(locationManager.closestPin?.name ?? "ERROR")")
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Text("Description: \(locationManager.closestPin?.description ?? "ERROR")")
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Display current latitude and longitude
                let coordinate = locationManager.region.center
                Text("Location: \(coordinate.latitude), \(coordinate.longitude)")
                    .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                // Show a progress spinner if a job is in progress
                if isLoading {
                    ProgressView("Processing NFT...")
                        .padding()
                        .foregroundStyle(.lavender)
                }
                
                Spacer()
                
                // Submit button
                Button(action: {
                    submitNFT()
                }) {
                    Text("Collect NFT")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    func submitNFT() {
        // Ensure the username is available.
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            errorMessage = "Your username was not found."
            return
        }
        
        guard let closestPin = locationManager.closestPin else {
            errorMessage = "NO PINS FOUND"
            return
        }
        
        isLoading = true
        let baseURL = URL(string: "http://ec2-35-170-185-57.compute-1.amazonaws.com")!
        guard let url = URL(string: "/collect", relativeTo: baseURL) else {
            print("Error: cannot create URL")
            return
        }
        
        // Create a unique boundary string for the multipart/form-data.
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Helper function to append a form field.
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Append the required fields.
        appendFormField(name: "username", value: username)
        appendFormField(name: "nft_id", value: closestPin.id.uuidString.lowercased())
        
        // Close the form.
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Upload error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server."
                    self.isLoading = false
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool, success,
                   let qid = json["qid"] as? String {
                    print("Server response: \(json)")
                    // Start polling for job status.
                    DispatchQueue.main.async {
                        self.pollJobStatus(qid: qid)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to start NFT collection job."
                        self.isLoading = false
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse server response: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    func pollJobStatus(qid: String) {
        // Poll the job status every 5 seconds.
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            let baseURL = URL(string: "http://ec2-35-170-185-57.compute-1.amazonaws.com")!
            guard let url = URL(string: "/job_status/\(qid)", relativeTo: baseURL) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let statusDict = json["status"] as? [String: Any],
                           let jobStatus = statusDict["status"] as? String {
                            print("json: \(json)")
                            print("Job Status: \(jobStatus)")
                            // Check if the job is no longer pending or running.
                            if (jobStatus.lowercased() != "pending" && jobStatus.lowercased() != "running") {
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    timer.invalidate()
                                    if jobStatus.lowercased() == "completed" {
                                        print("NFT collection completed successfully.")
                                        // Hide the collection menu or perform any additional UI updates.
                                        showMintMenu = false
                                    } else {
                                        self.errorMessage = "Job ended with status: \(jobStatus)"
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error parsing job status response")
                    }
                }
            }.resume()
        }
    }
}


