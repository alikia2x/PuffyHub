//
//  TimeLineView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI

struct SpinnerView: View {
  var body: some View {
    ProgressView()
      .progressViewStyle(CircularProgressViewStyle())
  }
}

enum TimeLineType: String {
    case home
    case local
    case hybrid
    case global
}

let type_APIString: [TimeLineType: String] = [
    .home: "notes/timeline",
    .local: "notes/local-timeline",
    .hybrid: "notes/hybrid-timeline",
    .global: "notes/global-timeline"
]

struct TimeLineView: View {
    var token: String
    var server: String
    var TLType: TimeLineType
    private var APIString: String
    
    @State private var results = [MKNote]()
    @State private var statusCode: Int = 0
    @State private var loading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var lastLoadedId: String? = nil
    
    init(token: String, server: String, TLType: TimeLineType) {
        self.token = token
        self.server = server
        self.TLType = TLType
        self.APIString = type_APIString[TLType] ?? ""
        self.results = results
        self.statusCode = statusCode
        self.loading = loading
        self.isLoadingMore = isLoadingMore
        self.lastLoadedId = lastLoadedId
    }
    
    func loadData(sinceId: String? = nil) async {
        let postBody = timelineRequest(
            withRenotes: true,
            limit: 10,
            untilId: sinceId,
            // Unfortunately, Misskey's untilId/sinceId doesn't make sense.
            // All in all, this works.
            allowPartial: true
        )
        if sinceId == nil {
            loading = true
        } else {
            isLoadingMore = true
        }
        var response: RequestResponse = await MKAPIRequest(server: server, endpoint: APIString, postBody: postBody, token: token)
        if response.success == false {
            return
        }
        
        statusCode = (response.response as! HTTPURLResponse).statusCode
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String: Any]] {
            var tempResults: [MKNote] = []
            for jsonDict in jsonArray {
                if let postData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
                   let postItem = try? JSONDecoder().decode(MKNote.self, from: postData) {
                    tempResults.append(postItem)
                } else {
                    print("ERR:", jsonDict.keys)
                }
            }
            if sinceId == nil {
                results = tempResults
            } else {
                results.append(contentsOf: tempResults)
            }
            if let last = tempResults.last {
                lastLoadedId = last.id
            }
        } else {
            print("Failed to parse JSON")
        }
        
        if sinceId == nil {
            loading = false
        } else {
            isLoadingMore = false
        }
    }

    
    var body: some View {
        VStack {
            if (statusCode == 200 && loading == false) {
                List {
                    Button(action: {
                        Task {
                            print("Refresh")
                            await loadData()
                        }
                    }) {
                        Text("Refresh")
                    }
                    ForEach(results, id: \.id) { item in
                        PostItem(name: item.user.name ?? "", username: "@"+item.user.username+"@"+(item.user.host ?? ""), content: item.text ?? "", avatar: item.user.avatarUrl, files: item.files)
                            .onAppear {
                                if item.id == results.last?.id && !isLoadingMore && !loading {
                                    Task {
                                        await loadData(sinceId: lastLoadedId)
                                    }
                                }
                            }
                    }
                    if isLoadingMore {
                        Text("Loading more...")
                    }
                }
            } else if loading == false {
                Text("Failed to load.")
                Button(action: {
                    Task {
                        await loadData()
                    }
                }, label: {
                    Text("Reload")
                })
            } else {
                SpinnerView()
            }
        }
        .task {
            await loadData()
        }
    }
}
