//
//  PostRichText.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import Foundation
import SwiftUI
import UIKit
import WatchKit
import SDWebImage
import SDWebImageSwiftUI
import SDWebImageWebPCoder

struct PostRichText: View {
    func handleURL(_ url: URL) -> OpenURLAction.Result {
        print("Handle \(url) somehow")
        openLink(url: url.absoluteString)
        return .handled
    }
    var rawText: String
    var body: some View {
        Text(markdownToAttributedString(rawText))
            .environment(\.openURL, OpenURLAction(handler: handleURL))
    }
}


#Preview {
    PostRichText(rawText: "Hello. **Bold** [Google](https://google.com)")
}
