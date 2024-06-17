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
        ScrollViewReader { proxy in
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
                        .onAppear(){
                            proxy.scrollTo(0)
                        }
                    }
                }
                PostItem(item: item)
                    .id(0)
                
                PostControls(item: item)
                
                if replyChildrenNote != nil{
                    LazyVStack {
                        ForEach(0..<replyChildrenNote!.count, id: \.self) { index in
                            NavigationLink(destination: {
                                PostDetailView(item: replyChildrenNote![index])
                                    .environmentObject(appSettings)
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
