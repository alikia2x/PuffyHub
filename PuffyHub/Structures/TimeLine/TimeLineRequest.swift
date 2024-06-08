//
//  TimeLineRequest.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

public struct timelineRequest: Encodable {
    var withFiles: Bool?;
    var withRenotes: Bool?;
    var limit: Int;
    var sinceId: String?;
    var untilId: String?;
    var sinceDate: Int?;
    var untilDate: Int?;
    var allowPartial: Bool?;
}
