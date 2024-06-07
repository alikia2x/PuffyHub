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

public enum TimeLineType: String {
    case home
    case local
    case hybrid
    case global
}

public let type_APIString: [TimeLineType: String] = [
    .home: "notes/timeline",
    .local: "notes/local-timeline",
    .hybrid: "notes/hybrid-timeline",
    .global: "notes/global-timeline"
]

public func loadData(timeline: TimeLineType, sinceId: String? = nil, timeLineData: TimeLineData, appSettings: AppSettings) async {
    let server = appSettings.server
    let token = appSettings.token
    
    let APIString = type_APIString[timeline]
    
    if (APIString == nil) {
        return
    }
    
    let postBody = timelineRequest(
        withRenotes: true,
        limit: 10,
        untilId: sinceId,
        // Unfortunately, Misskey's untilId/sinceId doesn't make sense.
        // All in all, this works.
        allowPartial: true
    )
    DispatchQueue.main.async {
        if sinceId == nil {
            timeLineData.loading = true
        } else {
            timeLineData.isLoadingMore = true
        }
    }
    
    let response: RequestResponse = await MKAPIRequest(server: server, endpoint: APIString!, postBody: postBody, token: token)
    if response.success == false {
        return
    }
    
    DispatchQueue.main.async {
        timeLineData.statusCode = (response.response as! HTTPURLResponse).statusCode
    }
    
    if let jsonArray = try? JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String: Any]] {
        DispatchQueue.main.async {
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
                timeLineData.timeline = tempResults
            } else {
                timeLineData.timeline.append(contentsOf: tempResults)
            }
            if let last = tempResults.last {
                timeLineData.lastLoadedId = last.id
            }
        }
    } else {
        print("Failed to parse JSON")
    }
    DispatchQueue.main.async {
        if sinceId == nil {
            timeLineData.loading = false
        } else {
            timeLineData.isLoadingMore = false
        }
    }
}

struct TimeLineView: View {
    var TLType: TimeLineType
    
    @EnvironmentObject var timeLineData: TimeLineData
    @EnvironmentObject var appSettings: AppSettings

    
    var body: some View {
        VStack {
            if (timeLineData.statusCode == 200 && timeLineData.loading == false) {
                List {
                    Button(action: {
                        Task {
                            print("Refresh")
                            await loadData(timeline: TLType, timeLineData: timeLineData, appSettings: appSettings)
                        }
                    }) {
                        Text("Refresh")
                    }
                    ForEach(timeLineData.timeline, id: \.id) { item in
                        PostItem(name: item.user.name ?? "", username: "@"+item.user.username+"@"+(item.user.host ?? ""), content: item.text ?? "", avatar: item.user.avatarUrl, files: item.files)
                            .onAppear {
                                if item.id == timeLineData.timeline.last?.id && !timeLineData.isLoadingMore && !timeLineData.loading {
                                    Task {
                                        await loadData(timeline: TLType, sinceId: timeLineData.lastLoadedId, timeLineData: timeLineData, appSettings: appSettings)
                                    }
                                }
                            }
                    }
                    if timeLineData.isLoadingMore {
                        Text("Loading more...")
                    }
                }
            } else if timeLineData.loading == false {
                Text("Failed to load.")
                Button(action: {
                    Task {
                        await loadData(timeline: TLType, timeLineData: timeLineData, appSettings: appSettings)
                    }
                }, label: {
                    Text("Reload")
                })
            } else {
                SpinnerView()
            }
        }
        .navigationTitle("Timeline")
    }
}
