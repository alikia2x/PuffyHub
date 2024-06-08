//
//  RichText.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import SwiftUI
import UIKit
import SDWebImage
import SDWebImageSwiftUI

// Enum to define regex patterns for Markdown syntax
enum MarkdownRegex: String {
    case bold = "\\*\\*(.*?)\\*\\*"
    case italic = "\\*(.*?)\\*"
    case username = #"(?<=(^|\s))@([A-Za-z0-9_])+(?=($|\s))"#
    case unifiedUsername = #"@([A-Za-z0-9_])+?@([A-Za-z0-9\-\.]+)\.([A-Za-z]+)(?=($|\s))"#

    case emoji = #":[A-Za-z0-9._]+:"#
    case hashtag = #"#[\u4E00-\u9FCCA-Za-z0-9_\.]+"#
    case repliesMentionPrefix = #"^((@([A-Za-z0-9_])+?@([A-Za-z0-9\-\.]+)\.([A-Za-z]+)) )+"#
    case mail = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}"#
    case link = #"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}\b([-a-zA-Z0-9@:%_\+.~#?&,//=]*)"#
    case idna = #"(xn--)(--)*[a-z0-9]+[^. ]"#

    case dollarAttribute = #"\$\[.+ .+\]"#

    case markdownAttachment = #"\[([^\]]*?)\]\(([^)]*?)\)"#
    case markdownBold = #"\*\*(.+?)\*\*(?!\*)"#
    case markdownStrikethrough = #"\~\~(.+?)\~\~(?!\~)"#
    case markdownMonospaceInline = #"`.+?`"#
    case markdownMonospaceMultiLine = "(?s)```(?:\\w+)?\\n(.*?)\\n```"
    case markdownQuote = #"^>.+$"#
}

// Typealias for the modification closure
typealias ModifyStringBlock = (_ string: NSMutableAttributedString) -> (NSMutableAttributedString?)

extension NSAttributedString {
    var full: NSRange { .init(location: 0, length: length) }
}

func enumerateModifying(string: NSMutableAttributedString, duringRanges ranges: [NSRange], operating: ModifyStringBlock) {
    var rangeFixup = 0
    var rangeRemapped = ranges
    rangeRemapped.sort { $0.location < $1.location }
    var currentTail = 0
    for range in rangeRemapped {
        let buildRange = NSRange(location: range.location + rangeFixup, length: range.length)
        guard buildRange.location != NSNotFound, buildRange.location >= 0, buildRange.upperBound <= string.length else {
            return
        }
        guard currentTail <= buildRange.location else {
            #if DEBUG
                print(
                    """
                    [*] CoreTextParser reported overlapping when enumerating over requested range
                        range start: \(buildRange) ... length \(buildRange.length)
                        accept tail: \(currentTail)
                        sub_string of request: \(string.attributedSubstring(from: buildRange).string)
                        request ignored
                    """
                )
            #endif
            continue
        }
        guard let subString = string.attributedSubstring(from: buildRange).mutableCopy() as? NSMutableAttributedString else {
            assertionFailure()
            continue
        }
        let originalString = subString.string
        guard originalString.utf16.count == subString.length else {
            assertionFailure()
            continue
        }
        guard let modifyRequest = operating(subString) else { continue }

        string.deleteCharacters(in: buildRange)
        string.insert(modifyRequest, at: buildRange.location)

        let positionShift = modifyRequest.length - originalString.utf16.count
        rangeFixup += positionShift

        currentTail = buildRange.location + modifyRequest.length
    }
}

func matchWithRegex(
    withinString string: NSMutableAttributedString,
    matching regex: MarkdownRegex,
    options: NSRegularExpression.Options = [.anchorsMatchLines]
) -> [NSTextCheckingResult] {
    guard let regexObject = try? NSRegularExpression(pattern: regex.rawValue, options: options) else {
        return []
    }
    let metaString = string.string
    guard metaString.utf16.count == string.length else {
        assertionFailure()
        return []
    }

    #if DEBUG
        let begin = Date()
    #endif

    let matchingResult = regexObject.matches(in: metaString, options: [], range: NSRange(location: 0, length: string.length))

    #if DEBUG
        let elapsedTime = abs(begin.timeIntervalSinceNow)
        if elapsedTime * 1000 > 1 {
            print(
                """
                [!] regex took too long to match this string
                    \(Int(elapsedTime * 1000))ms \(regex.rawValue) \(regex.rawValue)
                >>>
                \(metaString)
                <<<
                """
            )
        }
    #endif

    return matchingResult
}

// Function to perform regex matching and modification
func enumeratedModifyingWithRegex(
    withinString string: NSMutableAttributedString,
    matching regex: MarkdownRegex,
    options: NSRegularExpression.Options = [.anchorsMatchLines],
    operating: ModifyStringBlock
) {
    let matchingResult = matchWithRegex(withinString: string, matching: regex, options: options)
    guard !matchingResult.isEmpty else { return }
    enumerateModifying(string: string, duringRanges: matchingResult.map(\.range), operating: operating)
}

// Function to replace Markdown bold syntax with attributed string
func replaceAttributeForMarkdownBold(with string: NSMutableAttributedString) {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize;
    enumeratedModifyingWithRegex(withinString: string, matching: .bold) { string in
        string.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        ], range: string.full)
        // Remove the ** from the string
        if string.length > 4, string.string.hasPrefix("**"), string.string.hasSuffix("**") {
            string.deleteCharacters(in: NSRange(location: 0, length: 2))
            string.deleteCharacters(in: NSRange(location: string.length - 2, length: 2))
        }
        return string
    }
}

func replaceAttributeForMarkdownItalic(with string: NSMutableAttributedString) {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize;
    enumeratedModifyingWithRegex(withinString: string, matching: .italic) { string in
        string.addAttributes([
            .font: UIFont.italicSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        ], range: string.full)
        // Remove the * from the string
        if string.length > 2, string.string.hasPrefix("*"), string.string.hasSuffix("*") {
            string.deleteCharacters(in: NSRange(location: 0, length: 1))
            string.deleteCharacters(in: NSRange(location: string.length - 1, length: 1))
        }
        return string
    }
}

func replaceAttributeForMarkdownLink(with string: NSMutableAttributedString) {
    enumeratedModifyingWithRegex(withinString: string, matching: .markdownAttachment) { subString in
        guard subString.string.hasPrefix("["),
              subString.string.contains("]"),
              subString.string.contains("("),
              subString.string.hasSuffix(")")
        else {
            return subString
        }
        var link = subString.string.components(separatedBy: "]")
            .last ?? ""
        guard link.hasPrefix("("), link.hasSuffix(")") else { return subString }
        link.removeFirst()
        link.removeLast()
        if link.hasPrefix("<"), link.hasSuffix(">") {
            link.removeFirst()
            link.removeLast()
        }
        guard !link.isEmpty else { return subString }
        guard let finalURL = URL(string: link) else { return subString }

        var desc = subString.string
        desc = desc.components(separatedBy: "]").first ?? ""
        desc = desc.components(separatedBy: "[").last ?? ""
        subString.mutableString.setString(desc)
        
        subString.addAttributes([
            .foregroundColor: UIColor(.blue),
            .link: finalURL.absoluteString
        ], range: NSRange(location: 0, length: desc.count))
        
        return subString
    }
}

func replaceAttributeForLinks(with string: NSMutableAttributedString) {
    enumeratedModifyingWithRegex(withinString: string, matching: .link) { string in
        guard let url = URL(string: string.string) else { return string }

        string.addAttributes([
            .link: url,
            .foregroundColor: UIColor(.blue)
        ], range: NSRange(location: 0, length: string.length))
        
        return string
    }
}

func replaceAttributeForHashtags(with string: NSMutableAttributedString) {
    enumeratedModifyingWithRegex(withinString: string, matching: .hashtag) { string in
        string.addAttributes([
            .foregroundColor: UIColor(.orange)
        ], range: NSRange(location: 0, length: string.length))
        
        return string
    }
}

func replaceAttributeForMarkdownStrikethrough(with string: NSMutableAttributedString) {
    enumeratedModifyingWithRegex(withinString: string, matching: .markdownStrikethrough) { string in
        string.addAttributes([
            .strikethroughColor: UIColor(.primary),
            .strikethroughStyle: NSUnderlineStyle(Text.LineStyle.single).rawValue
        ], range: string.full)
        if string.length > 4, string.string.hasPrefix("~~"), string.string.hasSuffix("~~") {
            string.deleteCharacters(in: NSRange(location: 0, length: 2))
            string.deleteCharacters(in: NSRange(location: string.length - 2, length: 2))
        }
        return string
    }
}

func replaceAttributeForMarkdownMonospaceInline(with string: NSMutableAttributedString) {
    enumeratedModifyingWithRegex(withinString: string, matching: .markdownMonospaceInline) { string in
        string.addAttributes([
            .link: "",
            .foregroundColor: UIColor(.white),
            .font: UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize * 0.9, weight: .semibold),
            .backgroundColor: UIColor(.gray.opacity(0.2))
        ], range: string.full)
        if string.length >= 2, string.string.hasPrefix("`"), string.string.hasSuffix("`") {
            string.deleteCharacters(in: NSRange(location: 0, length: 1))
            string.deleteCharacters(in: NSRange(location: string.length - 1, length: 1))
        }
        return string
    }
}

func codeRanges(in markdown: String) -> (NSRange, NSRange)? {
    // 定义正则表达式模式，匹配Markdown代码块
    let pattern = "(?s)```(?:\\w+)?\\n(.*?)\\n```"
    
    // 创建正则表达式对象
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return nil
    }
    
    // 在markdown字符串中搜索匹配
    let range = NSRange(location: 0, length: markdown.utf16.count)
    guard let match = regex.firstMatch(in: markdown, options: [], range: range) else {
        return nil
    }
    
    // 获取代码部分的范围
    if let codeRange = Range(match.range(at: 1), in: markdown) {
        // 计算开始删除的范围
        let startDeleteRange = NSRange(location: 0, length: codeRange.lowerBound.utf16Offset(in: markdown))
        // 计算结束删除的范围，考虑到删除前面的范围后字符串长度的变化
        let endDeleteRange = NSRange(location: codeRange.upperBound.utf16Offset(in: markdown) - startDeleteRange.length, length: markdown.utf16.count - codeRange.upperBound.utf16Offset(in: markdown))
        
        return (startDeleteRange, endDeleteRange)
    }
    
    return nil
}

func replaceAttributeForMarkdownMonospaceMultiLine(with string: NSMutableAttributedString) {
    enumeratedModifyingWithRegex(withinString: string, matching: .markdownMonospaceMultiLine) { string in
        string.removeAttribute(.foregroundColor, range: string.full)
        string.addAttributes([
            .link: "",
            .foregroundColor: UIColor(.white),
            .font: UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize * 0.8, weight: .semibold)
        ], range: string.full)
        if let (startRange, endRange) = codeRanges(in: string.string) {
            if (startRange.location + startRange.length < string.length && endRange.location + endRange.length < string.length){
                string.deleteCharacters(in: startRange)
                string.deleteCharacters(in: endRange)
            }
        }
        return string
    }
}

// Function to convert raw Markdown string to AttributedString
func markdownToAttributedString(_ rawString: String) -> AttributedString {
    let mutableAttributedString = NSMutableAttributedString(string: rawString)
    
    // Set initial font size for whole text
    mutableAttributedString.setAttributes([
        .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
    ], range: NSRange(location: 0, length: mutableAttributedString.length))
    
    replaceAttributeForMarkdownBold(with: mutableAttributedString)
    replaceAttributeForMarkdownItalic(with: mutableAttributedString)
    replaceAttributeForMarkdownLink(with: mutableAttributedString)
    replaceAttributeForLinks(with: mutableAttributedString)
    replaceAttributeForHashtags(with: mutableAttributedString)
    replaceAttributeForMarkdownStrikethrough(with: mutableAttributedString)
    replaceAttributeForMarkdownMonospaceMultiLine(with: mutableAttributedString)
    replaceAttributeForMarkdownMonospaceInline(with: mutableAttributedString)
    
    return AttributedString(mutableAttributedString)
}

let previewMarkdown = """
Hello. **Bold** *Italic*
[Google](https://google.com)
https://example.com/
#tag ~~Strikethrough~~ 
Inline code: `var foo = 'inline code'`
A C program:
```c
#include <stdio.h>
int main() {
    printf("https://google.com/");
    return 0;
}
```
Small emoji: :nacho05:
"""



#Preview {
    ScrollView{
        VStack {
            PostRichText(rawText: previewMarkdown, postHost: nil, server: AppSettings.example.server)
        }
    }
    .environmentObject(AppSettings.example)
}
