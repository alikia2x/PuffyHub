//
//  AboutView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI


func getVersion() -> String{
    //First get the nsObject by defining as an optional anyObject
    let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject

    //Then just cast the object as a String, but be careful, you may want to double check for nil
    let version = nsObject as! String
    return version
}

struct AboutContent: View {
    var body: some View {
        VStack(alignment: .leading) {
            Label("PuffyHub " + getVersion(), systemImage: "info.circle")

            Label (
                title: {
                    Text("github.com/alikia2x/puffyhub")
                },
                icon: { Image(systemName: "books.vertical.circle") }
            )
            Spacer()
        }
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity,
          alignment: .topLeading
        )
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        TabView {
            NavigationStack {
                AboutContent()
                    .navigationTitle("About")
            }
        }.tabViewStyle(.page)
    }
}

#Preview {
    return AboutView()
}
