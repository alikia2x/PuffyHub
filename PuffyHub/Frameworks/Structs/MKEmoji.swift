//
//  MKEmoji.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/6.
//

import BetterCodable
import Foundation

public struct MKEmoji: Codable {
    public var name: String
    @LossyOptional public var category: String?
    @LossyOptional public var aliases: [String]?
}
