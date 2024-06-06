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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppSettings())
        }
    }
}
