//
//  PostItem.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/2.
//

import Foundation
import SwiftUI
import UIKit
import WatchKit
import SDWebImageSwiftUI
import SDWebImageWebPCoder

struct PostItem: View {
    var name: String
    var username: String
    var content: String
    var avatar: String?
    var files: [MKDriveFile]?;
    
    @ScaledMetric private var scale: CGFloat = 1;
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                WebImage(url: URL(string: avatar ?? ""), options: .progressiveLoad) { image in
                        image.resizable() // Control layout like SwiftUI.AsyncImage, you must use this modifier or the view will use the image bitmap size
                    } placeholder: {
                        Image(systemName:"person")
                            .imageScale(.large)
                    }
                    .onSuccess { image, data, cacheType in
                        
                    }
                    .indicator(.activity) // Activity Indicator
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
                    .scaledToFit()
                    .frame(width: 32 * scale, height: 32 * scale)
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                
                VStack(alignment: .leading){
                    Text(name)
                        .font(.caption .weight(.semibold))
                    Text(verbatim: username)
                        .font(.footnote .weight(.light))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Divider()
            PostRichText(rawText: content)
            if (files?.isEmpty == false){
                VStack{
                    ForEach(files!, id: \.id) { file in
                        WebImage(url: URL(string: file.thumbnailUrl ?? ""), options: .progressiveLoad) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName:"photo")
                                    .imageScale(.large)
                            }
                            .onSuccess { image, data, cacheType in
                            }
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                    }
                }
            }
        }
        .padding([.bottom, .top], 8)
        .onAppear{
            SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        }
    }
}


#Preview {
    List{
        PostItem(name: "User", username: "@user@example.com", content: "Post content\nLine 2\nVery very **LONG** content here, yes, it's very very long. ", avatar: "https://social.a2x.pub/files/02d2c204-5f14-4f5f-adc9-5779e6f323d6", files: [])
    }
}
