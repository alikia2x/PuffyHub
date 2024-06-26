//
//  ContentView.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/2.
//

import SwiftUI

public class AppSettings: ObservableObject {
    @AppStorage("token") var token: String = ""
    @AppStorage("instance") var server: String = ""
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
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        NavigationStack {
            TimeLineView()
        }
        NavigationStack {
            MeView()
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
                        await loadData(timeLineData: timeLineData, appSettings: appSettings)
                    }
            }
        }
        .tabViewStyle(.page)
        .environmentObject(AppSettings())
    }
}


#Preview {
    ContentView()
        .environmentObject(AppSettings.example)
        .environmentObject(TimeLineData())
}
