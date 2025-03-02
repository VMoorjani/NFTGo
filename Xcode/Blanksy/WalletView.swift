//
//  WalletView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

struct WalletView: View {
    var body: some View {
        let publicKey = UserDefaults.standard.string(forKey: "publicKey") ?? "defaultPublicKey"
        let urlString = "https://solscan.io/account/\(publicKey)?cluster=devnet"
        
        if let url = URL(string: urlString) {
            WebView(url: url)
        } else {
            Text("Invalid URL")
        }
    }
    
}
