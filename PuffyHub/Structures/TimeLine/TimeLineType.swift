//
//  TimeLineType.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

public enum TimeLineType: String {
    case home
    case local
    case hybrid
    case global
}

public let TLType_Image: [TimeLineType: String] = [
    .home: "house",
    .local: "server.rack",
    .hybrid: "person.2",
    .global: "globe"
]

public let TLType_Text: [TimeLineType: String] = [
    .home: "Home",
    .local: "Local",
    .hybrid: "Social",
    .global: "Global"
]

public let type_APIString: [TimeLineType: String] = [
    .home: "notes/timeline",
    .local: "notes/local-timeline",
    .hybrid: "notes/hybrid-timeline",
    .global: "notes/global-timeline"
]
