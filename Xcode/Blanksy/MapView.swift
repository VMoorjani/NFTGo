//
//  MapView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var showNFTMenu = false
    @State private var showMintMenu = false
    
    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $locationManager.region,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: locationManager.pins
            ) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .red)
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showNFTMenu = true
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                    })
                }
            }
            .padding()
            
            if (locationManager.closestPin != nil) {
                VStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 50)
                        .overlay(Text("Nearby point detected!").foregroundColor(.white))
                        .padding()
                        .onTapGesture(perform: {
                            self.showMintMenu = true
                        })
                    
                    Spacer()
                }
            }
            
        }
        
        .onAppear {
            locationManager.requestLocation()
        }
        .sheet(isPresented: $showNFTMenu, content: {
            CreateNFTView(showNFTMenu: $showNFTMenu)
        })
        .sheet(isPresented: $showMintMenu, content: {
            MintNFTView(showMintMenu: $showMintMenu)
        })

    }
}

#Preview {
    ContentView()
}
