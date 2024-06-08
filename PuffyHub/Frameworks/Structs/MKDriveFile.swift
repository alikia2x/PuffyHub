//
//  MKDriveFile.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import BetterCodable
import Foundation

public struct MKDriveFile: Codable {
    public var id: String
    @LossyOptional public var createdAt: String?
    public var name: String
    public var type: String
    @LossyOptional public var md5: String?
    @LossyOptional public var size: Int?
    public var isSensitive: Bool
    @LossyOptional public var blurhash: String?
    @LossyOptional public var properties: MKProperties?
    public var url: String
    @LossyOptional public var thumbnailUrl: String?
    @LossyOptional public var comment: String?
    @LossyOptional public var folderId: String?
    @LossyOptional public var userId: String?
//        @LossyOptional public var folder: MKUserLiteFolder?
    @LossyOptional public var user: MKUserLite?
}

public struct MKProperties: Codable {
    @LossyOptional public var height: Int?
    @LossyOptional public var width: Int?
    @LossyOptional public var orientation: Int?
    @LossyOptional public var avgColor: String?
}
