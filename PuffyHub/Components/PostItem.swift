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

let examplePost: MKNote = MKNote(
    id: "9u9afgousrp701do",
    createdAt: "2024-06-08T06:50:40.158Z",
    text: "我最喜欢的Mojave壁纸……终于回来了:anenw17:",
    userId: "9ou4jmix73gp0001",
    user: MKUserLite(
        id: "9ou4jmix73gp0001",
        name: "寒寒",
        username: "alikia",
        host: nil,
        avatarUrl: "https://social.a2x.pub/proxy/avatar.webp?url=https%3A%2F%2Fsocial.a2x.pub%2Ffiles%2F02d2c204-5f14-4f5f-adc9-5779e6f323d6&avatar=1"
    ),
    renoteCount: 2,
    repliesCount: 0,
    reactions: [:],
    fileIds: ["9u9af4szsrp701dn"],
    files: [
        MKDriveFile(
            id: "9u9af4szsrp701dn",
            name: "截屏2024-06-08 17.17.01.png.webp",
            type: "image/webp",
            isSensitive: false,
            url: "https://assets-social.a2x.pub/media/b2091528-2e52-4296-a081-ce1b2b264b14.webp",
            thumbnailUrl: "https://assets-social.a2x.pub/media/thumbnail-b3eeff8c-c863-4070-955f-92dc665251d8.webp"
        )
    ]
)

struct PostItem: View {
    var item: MKNote
    @EnvironmentObject var appSettings: AppSettings
    
    private var name: String
    private var username: String
    private var content: String
    private var avatar: String?
    private var files: [MKDriveFile]?;
    
    @ScaledMetric private var scale: CGFloat = 1;
    
    init(item: MKNote) {
        self.item = item
        self.name = item.user.name ?? ""
        self.username = "@"+item.user.username+(item.user.host==nil ? "" : "@")+(item.user.host ?? "")
        self.content = item.text ?? ""
        self.avatar = item.user.avatarUrl
        self.files = item.files
    }
    
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
                .cornerRadius(3.0)
                
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
            PostRichText(rawText: content, postHost: item.user.host, server: appSettings.server)
            PostFiles(files: item.files)
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
            PostTimeShort(time: item.createdAt)
        }
        .padding(.horizontal, 7.5)
        .padding(.vertical, 12.0)
        .background(.gray.opacity(0.2))
        .cornerRadius(7.0)
    }
}


#Preview {
    ScrollView{
        LazyVStack {
            PostItem(item: examplePost)
        }
    }
    .environmentObject(AppSettings.example)
}
