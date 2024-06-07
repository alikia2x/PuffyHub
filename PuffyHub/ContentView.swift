//
//  ContentView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/2.
//

import SwiftUI

struct GlobalTimelineResponse: Codable {
    var results: [MKNote]
}

struct timelineRequest: Encodable {
    var withFiles: Bool?;
    var withRenotes: Bool?;
    var limit: Int;
    var sinceId: String?;
    var untilId: String?;
    var sinceDate: Int?;
    var untilDate: Int?;
    var allowPartial: Bool?;
}

public class AppSettings: ObservableObject {
    @AppStorage("token") var token: String = ""
    @AppStorage("instance") var server: String = ""
}

extension AppSettings {
    static var example: AppSettings {
        let settings = AppSettings()
        settings.token = "wg8VBaCVPnHWqDV2ln4Z5li8K7UdQg8U"
        settings.server = "https://social.a2x.pub/"
        return settings
    }
}

public class TimeLineData: ObservableObject {
    @Published var timeline: [MKNote] = []
    @Published var timelineType: TimeLineType = .home
    @Published var statusCode: Int = 0
    @Published var loading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var lastLoadedId: String? = nil
}

struct MainAppView: View {
    @EnvironmentObject var timeLineData: TimeLineData
    var body: some View {
        NavigationStack {
            TimeLineView(TLType: timeLineData.timelineType)
        }
        NavigationStack {
            AboutView()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var timeLineData: TimeLineData
    @EnvironmentObject var appSettings: AppSettings
    
    
    var body: some View {
        TabView {
            if (appSettings.token == "" || appSettings.server == ""){
                NavigationStack {
                    IntroView()
                }
            }
            else {
                MainAppView()
                .task {
                    await loadData(timeline: .home, timeLineData: timeLineData, appSettings: appSettings)
                }
            }
        }
        .tabViewStyle(.page)
    }
}


#Preview {
    ContentView()
        .environmentObject(AppSettings.example)
        .environmentObject(TimeLineData())
}
