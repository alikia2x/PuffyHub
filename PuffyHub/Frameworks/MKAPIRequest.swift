//
//  MKAPIRequest.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/7.
//

import Foundation

public struct RequestResponse {
    var success: Bool
    var data: Data?
    var response: URLResponse?
}

func MKAPIRequest(server: String, endpoint: String, postBody: Encodable? = nil, token: String? = nil, method: String? = "POST", root: Bool? = false) async -> RequestResponse {
    guard let ServerURL = URL(string: server),
          let ServerEndpoint = (root! ? URL(string: "/", relativeTo: ServerURL) : URL(string: "/api/", relativeTo: ServerURL)),
          let url = URL(string: endpoint, relativeTo: ServerEndpoint) else {
        print("Invalid URL")
        return RequestResponse(success: false)
    }

    do {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = method
        if (postBody != nil) {
            request.httpBody = try JSONEncoder().encode(postBody!)
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if (token != nil) {
            request.setValue("Bearer " + token!, forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        return RequestResponse(success: true, data: data, response: response)
    } catch {
        return RequestResponse(success: false)
    }
}
