//
//  PuffyHubApp.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/2.
//

import SwiftUI
import UIKit
import WatchKit
import SDWebImageWebPCoder

class MyWatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    }
}

@main
struct PuffyHubApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: MyWatchAppDelegate
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
