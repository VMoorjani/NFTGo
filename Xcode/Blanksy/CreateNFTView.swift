import SwiftUI
import UIKit
import MapKit
import Photos

struct CreateNFTView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var nftName = ""
    @State private var nftDescription = ""
    @State private var errorMessage: String?
    @State private var isLoading = false  // Track whether the job is in progress
    @Binding var showNFTMenu: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image selection view
                Group {
                    if let image = selectedImage {
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
                                Text("Tap to select an image")
                                    .foregroundColor(.gray)
                            )
                            .cornerRadius(8)
                    }
                }
                .onTapGesture {
                    showImagePicker = true
                }
                
                TextField("Enter NFT Name", text: $nftName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                TextField("Enter description", text: $nftDescription)
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
                    Text("Submit NFT")
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    func submitNFT() {
        let coordinate = locationManager.region.center
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            errorMessage = "Your username was not found."
            return
        }
        
        if selectedImage == nil {
            errorMessage = "The image cannot be blank"
            return
        }
        if nftName.isEmpty {
            errorMessage = "NFT Name cannot be blank"
            return
        }
        if nftDescription.isEmpty {
            errorMessage = "NFT Description cannot be blank"
            return
        }

        guard let imageData = selectedImage?.pngData() else {
            errorMessage = "Could not process image."
            return
        }
        print("Image size: \(imageData.count) bytes")
        isLoading = true
        // Specify your server endpoint.
        let baseURL = URL(string: "http://ec2-35-170-185-57.compute-1.amazonaws.com")!
        guard let url = URL(string: "/upload", relativeTo: baseURL) else {
            print("error 1")
            return
        }
        
        // Create a unique boundary string.
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        appendFormField(name: "username", value: username)
        appendFormField(name: "name", value: nftName)
        appendFormField(name: "description", value: nftDescription)
        appendFormField(name: "latitude", value: "\(coordinate.latitude)")
        appendFormField(name: "longitude", value: "\(coordinate.longitude)")
        
        let filename = "\(UUID().uuidString).png"
        let mimetype = "image/png"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Upload error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server."
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool,
                   success,
                   let qid = json["qid"] as? String {
                    print("Server response: \(json)")
                    // Start polling the job status once you have the job ID.
                    DispatchQueue.main.async {
                        self.pollJobStatus(qid: qid)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to start NFT job."
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func pollJobStatus(qid: String) {
        // Poll the job status every 2 seconds.
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            let baseURL = URL(string: "http://ec2-35-170-185-57.compute-1.amazonaws.com")!
            guard let url = URL(string: "/job_status/\(qid)", relativeTo: baseURL) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let statusDict = json["status"] as? [String: Any],
                           let jobStatus = statusDict["status"] as? String {
                            print("Job Status: \(jobStatus)")
                            if (jobStatus.lowercased() != "pending" && jobStatus.lowercased() != "running") {
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    timer.invalidate()
                                    if jobStatus.lowercased() == "completed" {
                                        print("NFT creation completed successfully.")
                                        var coordinate: CLLocationCoordinate2D {
                                            CLLocationCoordinate2D(latitude: locationManager.region.center.latitude, longitude: locationManager.region.center.longitude)
                                        }
                                        locationManager.fetchPoints(for: coordinate)
                                        showNFTMenu = false
                                        
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

#Preview {
    ContentView()
}
