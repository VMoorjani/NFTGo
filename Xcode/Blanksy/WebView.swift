//
//  WebView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/2/25.
//

import Foundation
import UIKit
import WebKit

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view if needed
    }
}

class WebViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        // Setup Auto Layout constraints
        webView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.topAnchor.constraint(equalTo: view.topAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
        let publicKey = UserDefaults.standard.string(forKey: "publicKey") ?? "defaultPublicKey"
        
        let urlString = "https://solscan.io/account/\(publicKey)?cluster=devnet"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

