//
//  OpenLink.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

import Foundation
import AuthenticationServices

func openLink(url: String) {
    guard let swift_URL = URL(string: url) else { return }
    // Source: https://www.reddit.com/r/apple/comments/rcn2h7/comment/hnwr8do/
    let session = ASWebAuthenticationSession(url: swift_URL, callbackURLScheme: nil) { _, _ in }
    session.prefersEphemeralWebBrowserSession = true
    session.start()
}
