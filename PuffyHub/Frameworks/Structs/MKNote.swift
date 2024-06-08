//
//  MKNote.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import BetterCodable
import Foundation

public struct MKNote: Codable {
    public var id: String
    public var createdAt: String
    @LossyOptional public var cw: String?
    @LossyOptional public var text: String?
    public var userId: String
    public var user: MKUserLite
    @LossyOptional public var visibility: String?
    @LossyOptional public var emojis: [MKEmoji]?
    @LossyOptional public var renoteCount: Int?
    @LossyOptional public var repliesCount: Int?
    @LossyOptional public var reactions: [String: Int]?
    @LossyOptional public var myReaction: String?
    @LossyOptional public var uri: String?
    @LossyOptional public var url: String?
    @LossyOptional public var fileIds: [String]?
    @LossyOptional public var channelId: String?
    @LossyOptional public var files: [MKDriveFile]?
    @LossyOptional public var localOnly: Bool?
    @LossyOptional public var tags: [String]?
    @LossyOptional public var isHidden: Bool?
    @LossyOptional public var renoteId: String?
    @LossyOptional public var visibleUserIds: [String]?
    @LossyOptional public var replyId: String?
    @LossyOptional public var mentions: [String]?
    @LossyOptional public var poll: MKNotePoll?
    @LossyOptional public var isReposted: Bool?
    @LossyOptional public var repostUser: MKUserLite?
}

public struct MKNoteReaction: Codable {
    public var id: String
    public var createdAt: String
    public var user: MKUserLite
    public var type: String
}

public struct MKNotePoll: Codable {
    public var multiple: Bool
    @LossyOptional public var expiresAt: String?
    public var choices: [MKNotePollChoice]
}

public struct MKNotePollChoice: Codable {
    public var text: String
    public var votes: Int
    public var isVoted: Bool
}
