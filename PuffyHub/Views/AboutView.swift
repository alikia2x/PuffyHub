//
//  AboutView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI


func getVersion() -> String {
    //First get the nsObject by defining as an optional anyObject
    let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject

    //Then just cast the object as a String, but be careful, you may want to double check for nil
    let version = nsObject as! String
    return version
}

func getLicense() -> String {
    if let url = Bundle.main.url(forResource: "LICENSE", withExtension: nil),
       let str = try? String(contentsOfFile: url.path)
    {
        return str
    } else {
        return ""
    }
}

struct LicenseText: View {
    @State var isExpanded = false
    var body: some View {
        Label (
            title: {
                HStack{
                    Text("License ")
                        .bold()
                    Spacer()
                    Text(">")
                        .rotationEffect(Angle(degrees: (isExpanded ? 90 : 0)), anchor: .center)
                }
                
            },
            icon: { Image(systemName: "building.columns") }
        )
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
        Spacer()
        if isExpanded {
            Text(getLicense())
                .monospaced()
                .font(.system(size: 10))
        }
    }
}

struct AboutContent: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Label("PuffyHub " + getVersion(), systemImage: "info.circle")
                Spacer()
                Label("alikia2x", systemImage: "person.circle")
                Spacer()
                Label(
                    title: {
                        Text("github.com/alikia2x/puffyhub")
                    },
                    icon: { Image(systemName: "books.vertical.circle") }
                )
                Spacer()
                Label("Special thanks: Lakr233", systemImage: "heart.circle")
                Spacer()
                Button("Log out", action: {
                    appSettings.server=""
                    appSettings.token=""
                })
                Spacer()
                LicenseText()
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
}

struct AboutView: View {
    var body: some View {
        AboutContent()
            .navigationTitle("About")
    }
}

#Preview {
    return AboutView()
}
