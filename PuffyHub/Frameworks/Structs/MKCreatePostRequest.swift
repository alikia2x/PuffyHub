//
//  MKCreatePostRequest.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/9.
//

import BetterCodable
import Foundation

public struct MKCreatePostRequest: Codable {
    @LossyOptional public var text: String?
//    @LossyOptional public var fileIds: [String]?
    @LossyOptional public var poll: Poll?
    @LossyOptional public var cw: String?
    public var localOnly: Bool = false
    public var visibility: String = "public"
    public var fileIds: [String]?
    @LossyOptional public var visibleUserIds: [String]?

    public struct Poll: Codable {
        @LossyOptional public var expiresAt: Int? // in ms, Date().timeIntervalSince1970 * 1000
        public var choices: [String]
        public var multiple: Bool

        public init(expiresAt: Int?, choices: [String], multiple: Bool) {
            self.expiresAt = expiresAt
            self.choices = choices
            self.multiple = multiple
        }
    }

    public init(
        text: String?,
        fileIds: [String]?,
        poll: MKCreatePostRequest.Poll?,
        cw: String?,
        localOnly: Bool = false,
        visibility: String = "public",
        visibleUserIds: [String]?
    ) {
        self.text = text
        self.poll = poll
        self.cw = cw
        self.localOnly = localOnly
        self.visibility = visibility
        self.visibleUserIds = visibleUserIds
        if (fileIds != nil) {
            self.fileIds = fileIds
        }
    }
}
