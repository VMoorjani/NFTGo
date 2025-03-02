//
//  ContentView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State var selectedTab = 2

    var body: some View {
        TabView(selection: $selectedTab) {
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(2)
            
            WalletView()
                .tabItem {
                    Label("Wallet", systemImage: "tray.full")
                }
                .tag(3)
        }
        .environmentObject(locationManager)
        .toolbarBackground(.indigo, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .onAppear {
            UITabBar.appearance().backgroundColor = .lavender
        }
    }
}

#Preview {
    ContentView()
}
