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
        guard let ServerURL = URL(string: server),
              let ServerEndpoint = URL(string: "/api/", relativeTo: ServerURL),
              let url = URL(string: APIString, relativeTo: ServerEndpoint) else {
            print("Invalid URL")
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let postBody = timelineRequest(
                withRenotes: true,
                limit: 10,
                untilId: sinceId,
                // Unfortunately, Misskey's untilId/sinceId doesn't make sense.
                // All in all, this works.
                allowPartial: true
            )
            request.httpBody = try JSONEncoder().encode(postBody)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            if sinceId == nil {
                loading = true
            } else {
                isLoadingMore = true
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            statusCode = (response as! HTTPURLResponse).statusCode
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
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
        } catch {
            print("Invalid data")
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
