//
//  PostControls.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 6/17/24.
//

import SwiftUI

struct PostControls: View {
    var item: MKNote
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingConfirmationDialog: Bool = false
    @State private var postDeleted: Bool = false
    @State private var postHearted: Bool = false
    
    var body: some View {
        HStack {
            // Like
            Button(action: {
                Task {
                    let server = appSettings.server
                    let token = appSettings.token
                    var response: RequestResponse
                    if postHearted {
                        let postBody = noteDetailRequest(noteId: item.id)
                        response = await MKAPIRequest(server: server, endpoint: "notes/reactions/delete", postBody: postBody, token: token)
                    }
                    else {
                        let postBody = noteReactRequest(noteId: item.id, reaction: "❤️")
                        response = await MKAPIRequest(server: server, endpoint: "notes/reactions/create", postBody: postBody, token: token)
                    }
                    if response.success == false || response.response == nil{
                        return
                    }
                    let statusCode = (response.response as! HTTPURLResponse).statusCode
                    if statusCode == 204 {
                        postHearted.toggle()
                    }
                }
            }) {
                if postHearted {
                    Image(systemName: "heart.fill")
                }
                else {
                    Image(systemName: "heart")
                }
                
            }
            .onAppear(){
                postHearted = item.myReaction != nil
            }
            .buttonBorderShape(.roundedRectangle(radius: 6.0))
            
            
            // Reply
            NavigationLink(destination: {
                PostView(replyId: item.id)
            }, label: {
                Image(systemName: "arrowshape.turn.up.left")
            })
            .buttonBorderShape(.roundedRectangle(radius: 6.0))
            
            
            // Delete
            Button(action: {
                showingConfirmationDialog = true
            }) {
                if postDeleted {
                    Image(systemName: "trash.slash")
                } else {
                    Image(systemName: "trash")
                }
            }
            .confirmationDialog(
                Text("Confirm Delete?"),
                isPresented: $showingConfirmationDialog,
                titleVisibility: .automatic,
                actions: {
                    Button("Delete", role: .destructive) {
                        Task {
                            let server = appSettings.server
                            let token = appSettings.token
                            
                            let postBody = noteDetailRequest(noteId: item.id)

                            let response: RequestResponse = await MKAPIRequest(server: server, endpoint: "notes/delete", postBody: postBody, token: token)
                            let statusCode = (response.response as! HTTPURLResponse).statusCode
                            if statusCode == 204 {
                                postDeleted = true
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
            .disabled(postDeleted)
            .buttonBorderShape(.roundedRectangle(radius: 6.0))
        }
    }
}

#Preview {
    NavigationStack {
        PostControls(item: examplePost)
            .environmentObject(AppSettings.example)
    }
}
