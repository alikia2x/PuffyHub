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
        ScrollView{
            VStack {
                Label("Enter your instance's host address below:", systemImage: "server.rack")
                    .font(.caption2)
                Spacer()
                TextField("eg: misskey.io", text: $server)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                Spacer()
                Button(action: {
                    let baseURL = (server.hasPrefix("https://") ? server : "https://" + server)
                    print(baseURL)
                }, label: {
                    Text("Log in")
                })
                Spacer()
            }
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
