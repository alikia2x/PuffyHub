//
//  PostView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/9.
//

import Foundation
import SwiftUI

struct PostView: View {
    @State private var postText: String = ""
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        TextField("Post content...", text: $postText)
        Button(action: {
            
        }, label: {
            Label("Send", systemImage: "paperplane")
        })
    }
}

#Preview {
    PostView()
        .environmentObject(AppSettings.example)
}
