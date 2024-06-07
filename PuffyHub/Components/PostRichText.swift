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
    var rawText: String
    var body: some View {
        Text(markdownToAttributedString(rawText))
    }
}


#Preview {
    PostRichText(rawText: "Post content\nLine 2\nVery very **LONG** content here, yes, it's very very long.@alikia@m.cmx.im")
}
