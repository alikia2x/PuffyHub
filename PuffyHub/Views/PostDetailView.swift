//
//  PostDetailView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 6/15/24.
//

import SwiftUI

public struct noteDetailRequest: Encodable {
    var noteId: String
}

public struct noteRepliesRequest: Encodable {
    var noteId: String
    var limit: Int
}

public struct noteReactRequest: Encodable {
    var noteId: String
    var reaction: String
}

struct PostDetailView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State var parentNote: MKNote? = nil
    @State var replyChildrenNote: [MKNote]? = nil
    @State private var showingConfirmationDialog: Bool = false
    @State private var postDeleted: Bool = false
    @State private var postHearted: Bool = false
    
    
    func loadParent(noteId: String) async {
        let server = appSettings.server
        let token = appSettings.token

        let postBody = noteDetailRequest(noteId: noteId)
        
        let response: RequestResponse = await MKAPIRequest(server: server, endpoint: "notes/show", postBody: postBody, token: token)
        if response.success == false || response.data == nil {
            print("Request Failed")
            return
        }
        if let jsonObject = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
            if let postData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
               let postItem = try? JSONDecoder().decode(MKNote.self, from: postData) {
                parentNote = postItem
            }
            else {
                print("Failed to decode")
            }
            
        } else {
            print("Failed to parse JSON")
        }
    }
    
    func loadChildrenReply(noteId: String) async {
        let server = appSettings.server
        let token = appSettings.token

        let postBody = noteRepliesRequest(noteId: noteId, limit: 30)
        
        let response: RequestResponse = await MKAPIRequest(server: server, endpoint: "notes/children", postBody: postBody, token: token)
        if response.success == false || response.data == nil {
            print("Request Failed")
            return
        }
        if let jsonArray = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String: Any]] {
            replyChildrenNote = []
            for jsonDict in jsonArray {
                if let postData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
                   let postItem = try? JSONDecoder().decode(MKNote.self, from: postData) {
                    replyChildrenNote?.append(postItem)
                }
                else {
                    print("Failed to decode")
                }
            }
        } else {
            print("Failed to parse JSON")
        }
    }
    
    var item: MKNote
    var body: some View {
        ScrollView {
            if (item.replyId != nil || item.renoteId != nil) {
                if (parentNote == nil) {
                    SpinnerView()
                }
                else {
                    NavigationLink(destination: {
                        PostDetailView(item: parentNote!)
                    }, label: {
                        PostItem(item: parentNote!)
                            .padding(.leading, 5)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            PostItem(item: item)
            HStack {
                Button(action: {
                    showingConfirmationDialog = true
                }) {
                    if postDeleted {
                        Image(systemName: "trash.slash")
                    }
                    else {
                        Image(systemName: "trash")
                    }
                }
                .confirmationDialog(Text("Confirm Delete?"),
                    isPresented: $showingConfirmationDialog,
                    titleVisibility: .automatic,
                    actions: {
                        Button("Delete", role: .destructive) {
                            Task {
                                let server = appSettings.server
                                let token = appSettings.token

                                let postBody = noteDetailRequest(noteId: item.id)
                                
                                let response: RequestResponse = await MKAPIRequest(server: server, endpoint: "notes/delete", postBody: postBody, token: token)
                                if response.success == false || response.response == nil{
                                    postDeleted = false
                                    return
                                }
                                let statusCode = (response.response as! HTTPURLResponse).statusCode
                                if statusCode == 204 {
                                    postDeleted = true
                                }
                                else {
                                    postDeleted = false
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
                .disabled(postDeleted)
                .buttonBorderShape(.roundedRectangle(radius: 6.0))
                
                NavigationLink(destination: {
                    PostView(replyId: item.id)
                }, label: {
                    Image(systemName: "arrowshape.turn.up.left")
                })
                .buttonBorderShape(.roundedRectangle(radius: 6.0))
                
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
            }
            
            .buttonBorderShape(.roundedRectangle(radius: 10.0))
            if replyChildrenNote != nil{
                LazyVStack {
                    ForEach(0..<replyChildrenNote!.count) { index in
                        NavigationLink(destination: {
                            PostDetailView(item: replyChildrenNote![index])
                        }, label: {
                            PostItem(item: replyChildrenNote![index])
                                .padding(.leading, 5)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .task {
            if item.replyId != nil {
                await loadParent(noteId: item.replyId!)
            }
            else if item.renoteId != nil {
                await loadParent(noteId: item.renoteId!)
            }
            await loadChildrenReply(noteId: item.id)
        }
    }
}

#Preview {
    let previewTLData = TimeLineData()
    let previewSettings = AppSettings.example
    NavigationStack {
        PostDetailView(item: examplePost)
            .environmentObject(previewSettings)
            .environmentObject(previewTLData)
    }
}
