//
//  BlanksyApp.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import SwiftUI

@main
struct BlanksyApp: App {
    @AppStorage("username") var username: String?
        
    var body: some Scene {
        WindowGroup {
            if let username = username, !username.isEmpty {
                ContentView()
            } else {
                AuthView()
            }
        }
    }

}
