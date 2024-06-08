import SwiftUI
import SDWebImage

// 自定义结构，表示文本和图片的组合
struct TextWithImage {
    var text: String
    var imageUrl: URL? // 图片URL，如果没有图片则为nil
}

// 正则预处理器
func processRawText(rawText: String, postHost: String?, userHost: String) -> [TextWithImage] {
    let regex = try! NSRegularExpression(pattern: ":(\\w+):", options: [])
    let nsString = rawText as NSString
    let matches = regex.matches(in: rawText, options: [], range: NSRange(location: 0, length: nsString.length))

    var result: [TextWithImage] = []
    var lastIndex = 0

    for match in matches {
        let matchRange = match.range
        let emojiKeyRange = match.range(at: 1)
        
        // Append text before the emoji
        if lastIndex < matchRange.location {
            let text = nsString.substring(with: NSRange(location: lastIndex, length: matchRange.location - lastIndex))
            result.append(TextWithImage(text: text, imageUrl: nil))
        }
        
        // Get the emoji key
        let emojiKey = nsString.substring(with: emojiKeyRange)
        let imageUrl = getEmojiUrl(emojiKey: emojiKey, postHost: postHost, userHost: userHost)
        result.append(TextWithImage(text: "", imageUrl: imageUrl))
        
        lastIndex = matchRange.location + matchRange.length
    }

    // Append remaining text
    if lastIndex < nsString.length {
        let text = nsString.substring(from: lastIndex)
        result.append(TextWithImage(text: text, imageUrl: nil))
    }

    return result
}

func getEmojiUrl(emojiKey: String, postHost: String?, userHost: String) -> URL? {
    guard let endpoint = URL(string: userHost)?.appendingPathComponent("emoji") else { return nil }
    // Posted on local server
    if (postHost == nil) {
        return endpoint.appendingPathComponent("\(emojiKey).webp")
    } 
    // Add remote server
    else {
        return endpoint.appendingPathComponent("\(emojiKey)@\(postHost!).webp")
    }
}

struct PostRichText: View {
    let rawText: String
    let postHost: String?
    let server: String
    
    @State private var cgImages: [URL: CGImage] = [:]
    
    func handleURL(_ url: URL) -> OpenURLAction.Result {
        print("Handle \(url) somehow")
        openLink(url: url.absoluteString)
        return .handled
    }
    
    var body: some View {
        let processedContent = processRawText(rawText: rawText, postHost: postHost, userHost: server)
        let combinedText = processedContent.reduce(Text("")) { (result, item) in
            if let imageUrl = item.imageUrl, let cgImage = cgImages[imageUrl] {
                return result + Text(Image(uiImage: UIImage(cgImage: cgImage)))
            } else {
                let attributedString = markdownToAttributedString(item.text)
                return result + Text(attributedString)
            }
        }
        
        return VStack {
            combinedText
        }
        .onAppear {
            loadImages(content: processedContent)
        }
        .environment(\.openURL, OpenURLAction(handler: handleURL))
    }
    
    private func loadImages(content: [TextWithImage]) {
        let group = DispatchGroup()
        
        for item in content {
            guard let url = item.imageUrl else { continue }
            
            group.enter()
            SDWebImageManager.shared.loadImage(
                with: url,
                options: [.fromLoaderOnly],
                context: [.storeCacheType: SDImageCacheType.none.rawValue],
                progress: nil,
                completed: { (image, data, error, cacheType, finished, url) in
                    if let resizedImage = resizeCGImage(image?.cgImage, toHeight: 22), let url = url {
                        DispatchQueue.main.async {
                            cgImages[url] = resizedImage
                        }
                    }
                    group.leave()
                }
            )
        }
        
        group.notify(queue: .main) {
            // All images have been loaded and resized
        }
    }
}

#Preview {
    PostRichText(rawText: "Hello world! :nacho05: This is a test.", postHost: nil, server: "https://social.a2x.pub")
}
