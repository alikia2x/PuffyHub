//
//  AppSettingsExample.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/9.
//

import Foundation

extension AppSettings {
    static var example: AppSettings {
        let settings = AppSettings()
        // You can generate a token at https://<YOUR_INSTANCE_HOST>/settings/api
        settings.token = "YOUR_TOKEN"
        // Fill the instance URL for previewing 
        settings.server = "YOUR_INSTANCE_HOST"
        return settings
    }
}
