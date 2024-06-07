//
//  IntroView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI
import QRCode

private let requestPermission = [
    "read:account",
    "read:drive",
    "read:favorites",
    "read:following",
    "read:mutes",
    "read:notifications",
    "read:reactions",
    "read:user",
    "write:account",
    "write:blocks",
    "write:favorites",
    "write:following",
    "write:mutes",
    "write:notes",
    "write:reactions",
    "write:user",
]
.joined(separator: ",")

struct LoginQRCode: View {
    @Binding var text: String
    private var doc: QRCode.Document {
        return QRCode.Document(text)!
    }
    var body: some View {
        Image(uiImage: doc.uiImage(CGSize(width: 170, height: 170))!)
    }
}

struct MIAuthCheckResponse: Codable {
    var token: String
    var user: MKUserDetails
}

struct LoginView: View {
    @State private var server: String = ""
    @State private var showingQRCode: Bool = false
    @State private var QRCodeText: String = ""
    @EnvironmentObject var appSettings: AppSettings
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
                    let UUID = UUID().uuidString
                    let finalEndpoint = "/miauth/" + UUID + "/?permission=" + requestPermission + "&name=PuffyHub"
                    guard let QRCodeURL = URL(string: finalEndpoint, relativeTo: URL(string: baseURL)!) else {
                        return
                    }
                    QRCodeText = QRCodeURL.absoluteString
                    showingQRCode = true

                    let checkEndpoint = "miauth/" + UUID + "/check"
                    Task {
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        while true {
                            struct rqBody: Codable {
                                var fuck: String
                            }
                            let response = await MKAPIRequest(server: baseURL, endpoint: checkEndpoint, postBody: rqBody(fuck: "fuck you"))
                            print((response.response as! HTTPURLResponse).statusCode)
                            if let decodedResponse = try? JSONDecoder().decode(MIAuthCheckResponse.self, from: response.data!) {
                                appSettings.token = decodedResponse.token
                                appSettings.server = baseURL
                                print("TOKEN: ", decodedResponse.token)
                                break
                            } else {
                                print("Failed to parse.")
                            }
                            if (showingQRCode==false) {
                                break
                            }
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                        }
                    }
                }, label: {
                    Text("Log in")
                })

                Spacer()
            }
            .fullScreenCover(isPresented: $showingQRCode, content: {
                LoginQRCode(text: $QRCodeText)
            })
        }
    }
}

struct IntroView: View {
    var body: some View {
        LoginView()
        .navigationTitle("Welcome")
    }
}

#Preview {
    return IntroView()
}
