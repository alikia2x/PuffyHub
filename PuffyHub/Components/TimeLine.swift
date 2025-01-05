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
            .progressViewStyle(.circular)
    }
}

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
                   var postItem = try? JSONDecoder().decode(MKNote.self, from: postData) {
                    if (jsonDict["renote"] == nil){
                        tempResults.append(postItem)
                    }
                    else {
                        if let renoteData = try? JSONSerialization.data(withJSONObject: jsonDict["renote"] as Any, options: []),
                           var renoteItem = try? JSONDecoder().decode(MKNote.self, from: renoteData) {
                            if (postItem.text != nil || postItem.cw != nil || postItem.fileIds != []) {
                                postItem.isReposted = true
                                postItem.repostUser = postItem.user
                                tempResults.append(postItem)
                            }
                            else {
                                renoteItem.id = postItem.id
                                renoteItem.createdAt = postItem.createdAt
                                renoteItem.isReposted = true
                                renoteItem.repostUser = postItem.user
                                tempResults.append(renoteItem)
                            }
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


struct TimeLineView: View {
    @EnvironmentObject var timeLineData: TimeLineData
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack {
            if (timeLineData.statusCode == 200 && timeLineData.loading == false) {
                ScrollView{
                    TimeLineControls()
                    LazyVStack {
                        ForEach(timeLineData.timeline, id: \.id) { item in
                            NavigationLink(destination: {
                                PostDetailView(item: item)
                            }){
                                PostItem(item: item)
                                    .onAppear {
                                        if item.id == timeLineData.timeline.last?.id && !timeLineData.isLoadingMore && !timeLineData.loading {
                                            Task {
                                                await loadData(sinceId: timeLineData.lastLoadedId, timeLineData: timeLineData, appSettings: appSettings)
                                            }
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                    }
                    if timeLineData.isLoadingMore {
                        SpinnerView()
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
    NavigationStack{
        let previewTLData = TimeLineData()
        let previewSettings = AppSettings.example
        TimeLineView()
            .environmentObject(previewSettings)
            .environmentObject(previewTLData)
            .onAppear(){
                Task {
                    await loadData(timeLineData: previewTLData, appSettings: previewSettings)
                }
            }
    }
}
