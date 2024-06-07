//
//  MeView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

import SwiftUI

struct MeView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var path = [Int]()
    var body: some View {
        VStack{
            ScrollView{
                VStack{
                    NavigationLink(destination: AboutView(), label: {
                        Text("About")
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 10.0))
                    Button("Log out", action: {
                        appSettings.server=""
                        appSettings.token=""
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 10.0))
                }
                
            }
            .navigationTitle("Me")
        }
    }
}

#Preview {
    NavigationStack {
        MeView()
            .environmentObject(AppSettings.example)
    }
}
