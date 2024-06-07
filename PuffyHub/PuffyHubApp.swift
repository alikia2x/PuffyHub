//
//  PuffyHubApp.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/2.
//

import SwiftUI
import UIKit
import WatchKit

@main
struct PuffyHubApp: App {
    @StateObject var appSettings = AppSettings()
    @StateObject var timeline = TimeLineData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environmentObject(timeline)
        }
    }
}
