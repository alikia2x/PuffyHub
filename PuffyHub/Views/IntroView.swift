//
//  IntroView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var server: String = ""
    var body: some View {
        VStack {
            Label("Enter your instance's host address below:", systemImage: "server.rack")
                .font(.caption2)
            TextField("eg: misskey.io", text: $server)
            Spacer()
        }
        
    }
}

struct IntroView: View {
    var body: some View {
        TabView {
            NavigationStack {
                LoginView()
                .navigationTitle("Welcome")
            }
        }.tabViewStyle(.page)
    }
}

#Preview {
    return IntroView()
}
