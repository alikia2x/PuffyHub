//
//  MKUserLite.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import BetterCodable
import Foundation

public struct MKUserLite: Codable {
    public var id: String
    @LossyOptional public var name: String?
    public var username: String
    @LossyOptional public var host: String?
    @LossyOptional public var avatarUrl: String?
    @LossyOptional public var avatarBlurhash: String?
    @LossyOptional public var avatarColor: String?
    @LossyOptional public var emojis: [MKEmoji]?
    @LossyOptional public var onlineStatus: String?
    @LossyOptional public var isAdmin: Bool?
    @LossyOptional public var isBot: Bool?
    @LossyOptional public var isModerator: Bool?
    @LossyOptional public var isCat: Bool?

    @LossyOptional public var instance: MKInstance?
}

public struct MKUserDetails: Codable {
    public var id: String

    @LossyOptional public var name: String?
    public var username: String
    @LossyOptional public var host: String?

    @LossyOptional public var avatarUrl: String?
    @LossyOptional public var avatarBlurhash: String?

    @LossyOptional public var isAdmin: Bool?
    @LossyOptional public var isModerator: Bool?
    @LossyOptional public var isBot: Bool?
    @LossyOptional public var isCat: Bool?

    @LossyOptional public var instance: MKInstance?
    @LossyOptional public var emojis: [MKEmoji]?

    @LossyOptional public var onlineStatus: String?

    @LossyOptional public var url: String?
    @LossyOptional public var uri: String?

    public var createdAt: String

    @LossyOptional public var bannerUrl: String?
    @LossyOptional public var bannerBlurhash: String?

    @LossyOptional public var description: String?
    @LossyOptional public var location: String?
    @LossyOptional public var birthday: String?
    @LossyOptional public var fields: [MKFields]?

    @LossyOptional public var followersCount: Int?
    @LossyOptional public var followingCount: Int?
    @LossyOptional public var notesCount: Int?

    @LossyOptional public var pinnedNoteIds: [String]?
    @LossyOptional public var pinnedNotes: [MKNote]?

    @LossyOptional public var ffVisibility: String?

    @LossyOptional public var isLocked: Bool?

    @LossyOptional public var isFollowing: Bool?
    @LossyOptional public var isFollowed: Bool?

    @LossyOptional public var hasPendingFollowRequestFromYou: Bool?
    @LossyOptional public var hasPendingFollowRequestToYou: Bool?

    @LossyOptional public var isBlocking: Bool?
    @LossyOptional public var isBlocked: Bool?

    @LossyOptional public var isMuted: Bool?

    @LossyOptional public var mutedWords: [[String]]?
}

public struct MKFields: Codable {
    public var name: String
    public var value: String
}
