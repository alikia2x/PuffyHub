//
//  TimeLineView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SpinnerView: View {
  var body: some View {
    ProgressView()
        .progressViewStyle(.circular)
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

public func loadData(sinceId: String? = nil, timeLineData: TimeLineData, appSettings: AppSettings) async {
    let server = appSettings.server
    let token = appSettings.token
    
    let timeline = timeLineData.timelineType
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
                    if (jsonDict["renote"] == nil){
                        tempResults.append(postItem)
                    }
                    else {
                        if let renoteData = try? JSONSerialization.data(withJSONObject: jsonDict["renote"] as Any, options: []),
                           var renoteItem = try? JSONDecoder().decode(MKNote.self, from: renoteData) {
                            renoteItem.isReposted = true
                            renoteItem.repostUser = postItem.user
                            tempResults.append(renoteItem)
                        }
                    }
                }
                else {
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

func openLink(url: String) {
    guard let swift_URL = URL(string: url) else {
        return
    }
    // Source: https://www.reddit.com/r/apple/comments/rcn2h7/comment/hnwr8do/
    let session = ASWebAuthenticationSession(
        url: swift_URL,
        callbackURLScheme: nil
    ) { _, _ in
    }
    session.prefersEphemeralWebBrowserSession = true
    session.start()
}


struct TimeLineView: View {
    @EnvironmentObject var timeLineData: TimeLineData
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack {
            if (timeLineData.statusCode == 200 && timeLineData.loading == false) {
                ScrollView{
                    VStack{
                        TimeLineControls()
                        LazyVStack {
                            ForEach(timeLineData.timeline, id: \.id) { item in
                                PostItem(item: item)
                                    .onAppear {
                                        if item.id == timeLineData.timeline.last?.id && !timeLineData.isLoadingMore && !timeLineData.loading {
                                            Task {
                                                await loadData(sinceId: timeLineData.lastLoadedId, timeLineData: timeLineData, appSettings: appSettings)
                                            }
                                        }
                                    }
                                Spacer()
                            }
                        }
                    }
                }
            } else if timeLineData.loading == false {
                Text("Failed to load.")
                Button(action: {
                    Task {
                        await loadData(timeLineData: timeLineData, appSettings: appSettings)
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

#Preview {
    TimeLineView()
        .environmentObject(AppSettings.example)
        .environmentObject(TimeLineData())
        
}
