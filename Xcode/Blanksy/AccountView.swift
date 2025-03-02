//
//  AccountView.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import SwiftUI

struct AccountView: View {
    @State private var shouldRedirect = false

    var body: some View {
        VStack {
            Button("Log Out", role: .destructive) {
                UserDefaults.standard.removeObject(forKey: "username")
                shouldRedirect = true
            }
            .buttonStyle(.borderedProminent)
            .frame(width: 200)

            NavigationLink(destination: AuthView(), isActive: $shouldRedirect) {
                EmptyView()
            }
        }
    }
}


#Preview {
    AccountView()
}
