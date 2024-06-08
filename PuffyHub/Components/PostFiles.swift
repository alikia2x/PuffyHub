//
//  PostFiles.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import SDWebImageWebPCoder

struct PostFiles: View {
    var files: [MKDriveFile]?
    var body: some View {
        if (files?.isEmpty == false){
            VStack{
                ForEach(files!, id: \.id) { file in
                    WebImage(url: URL(string: file.thumbnailUrl ?? ""), options: .progressiveLoad) { 
                        image in image.resizable()
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
            .onAppear{
                SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
            }
        }
    }
}
