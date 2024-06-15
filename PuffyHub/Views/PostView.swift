//
//  PostView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/9.
//

import Foundation
import SwiftUI

struct PostView: View {
    var replyId: String?
    @State private var postText: String = ""
    @State private var statusCode: Int = -1
    @State private var sending: Bool = false
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView {
            TextField("Post content...", text: $postText)
            Button(action: {
                let postBody = MKCreatePostRequest(text: postText, fileIds: nil, poll: nil, cw: nil, visibleUserIds: [], replyId: replyId)
                Task {
                    sending = true
                    let response: RequestResponse = await MKAPIRequest(server: appSettings.server, endpoint: "notes/create", postBody: postBody, token: appSettings.token)
                    sending = false
                    if response.success == false {
                        return
                    }
                    statusCode = (response.response as! HTTPURLResponse).statusCode
                }
            }, label: {
                Label("Send", systemImage: "paperplane")
            })
            .buttonBorderShape(.roundedRectangle(radius: 12))
            if (statusCode == 200) {
                Text("Sent.")
            }
            else if sending == true {
                Text("Sending...")
            }
            else if statusCode != -1{
                Text("Error.")
            }
        }
        .navigationTitle("Send Post")
    }
}

#Preview {
    NavigationStack {
        PostView()
            .environmentObject(AppSettings.example)
    }
}
