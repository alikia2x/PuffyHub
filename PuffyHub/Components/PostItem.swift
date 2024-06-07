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

let examplePost: MKNote = MKNote(id: "9u8jspbrfoen1thy", createdAt: "2024-06-07T17:52:08.247Z",
    text: "这两天听了无数遍 Porter Robinson 的 《Russian Roulette》，不得不说这是我近一两年来听过的最新颖的作品，没有定式，很抓耳（可能是出于商业导向整个专辑都有瞄准短视频制作 Drop），听起来很随意但又有深邃的情感表达，有很活泼的元素运用。\n\n拿起了吉他的 Porter 这一刻化身成了新时代的吟游诗人给我们说他自己的故事，是完完全全只属于他也只为了他而创作的音乐。\n\n在目前释出的三个曲目里这一首是目前为止我个人最喜欢且认为最登峰造极的一首，前两首在整体的编制方面虽然也不差，但是听着有相对更重的商业味道，而且对比这一首更平庸。\n\n不得不说，虽然我有粉丝滤镜，但是他确实是一个天才",
    userId: "9owfkrf3byt70v8c",
    user: MKUserLite(id: "9owfkrf3byt70v8c", name: "BackRunner", username: "backrunner", host: "pwp.space",
                    avatarUrl: "https://social.a2x.pub/proxy/avatar.webp?url=https%3A%2F%2Fassets-misskey.pwp.space%2Fnull%2F083c0af6-bff9-4564-9b85-33876a834175.webp&avatar=1"
    ), renoteCount: 2
)

func getRelativeTime(dateString: String) -> String{

    // 1. Parse the date string into a Date object
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    guard let date = isoDateFormatter.date(from: dateString) else {
        fatalError("Invalid date format")
    }

    // 2. Create a RelativeDateTimeFormatter
    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.unitsStyle = .full
    relativeFormatter.locale = Locale.current // Use the current locale

    // 3. Get the relative time string from the Date
    let relativeTimeString = relativeFormatter.localizedString(for: date, relativeTo: Date())

    // Print the result
    return relativeTimeString
}

struct PostItem: View {
    var item: MKNote
    
    private var name: String
    private var username: String
    private var content: String
    private var avatar: String?
    private var files: [MKDriveFile]?;
    
    init(item: MKNote) {
        self.item = item
        self.name = item.user.name ?? ""
        self.username = "@"+item.user.username+(item.user.host==nil ? "" : "@")+(item.user.host ?? "")
        self.content = item.text ?? ""
        self.avatar = item.user.avatarUrl
        self.files = item.files
    }
    
    
    @ScaledMetric private var scale: CGFloat = 1;
    var body: some View {
        VStack(alignment: .leading){
            if (item.isReposted != nil && item.isReposted!) {
                Text("Reposted by " + item.repostUser!.username)
            }
            
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
            Spacer()
            HStack{
                if (item.reactions != nil) {
                    Label(String(item.reactions!.count), systemImage: "heart")
                }
                if (item.renoteCount != nil) {
                    Label(String(item.renoteCount!), systemImage: "repeat")
                }
                if (item.repliesCount != nil) {
                    Label(String(item.repliesCount!), systemImage: "arrowshape.turn.up.left")
                }
            }
            Text(getRelativeTime(dateString: item.createdAt))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 7.5)
        .padding(.vertical, 12.0)
        .background(.gray.opacity(0.2))
        .cornerRadius(7.0)
        .onAppear{
            SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        }
    }
}


#Preview {
    ScrollView{
        LazyVStack {
            PostItem(item: examplePost)
        }
    }
}
