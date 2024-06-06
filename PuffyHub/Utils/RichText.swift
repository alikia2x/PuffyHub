//
//  RichText.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import SwiftUI
import UIKit

// Enum to define regex patterns for Markdown syntax
enum MarkdownRegex: String {
    case bold = "\\*\\*(.*?)\\*\\*"
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
//            #if DEBUG
//                debugPrint("[*] enumerator calling operation on range \(buildRange.location) \(buildRange.length) \(subString.string.components(separatedBy: "\n").joined(separator: " "))")
//            #endif
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

// Function to convert raw Markdown string to AttributedString
func markdownToAttributedString(_ rawString: String) -> AttributedString {
    let mutableAttributedString = NSMutableAttributedString(string: rawString)
    mutableAttributedString.setAttributes([
        .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
    ], range: NSRange(location: 0, length: mutableAttributedString.length))
    replaceAttributeForMarkdownBold(with: mutableAttributedString)
    // Add more replace functions here for other Markdown syntaxes
    return AttributedString(mutableAttributedString)
}

// SwiftUI view to display the Markdown text
struct MarkdownTextView: View {
    let rawString: String

    var body: some View {
        Text(markdownToAttributedString(rawString))
    }
}

#Preview {
    MarkdownTextView(rawString: "Hello. **Bold**")
}
