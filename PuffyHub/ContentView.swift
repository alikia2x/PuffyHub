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

class AppSettings: ObservableObject {
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

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    var body: some View {
        if (appSettings.token != "" && appSettings.server != ""){
            TimeLineView(token: appSettings.token, server: appSettings.server, TLType: .home)
        }
        else {
            IntroView()
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(AppSettings.example)
}
