//
//  HARArchive.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

struct HARArchive: Decodable {
    let log: Log

    struct Log: Decodable {
        let entries: [Entry]
    }

    struct Entry: Decodable {
        let request: RequestInfo
        let response: ResponseInfo
    }

    struct RequestInfo: Decodable {
        let method: String
        let urlString: String

        enum CodingKeys: String, CodingKey {
            case method = "method"
            case urlString = "url"
        }

        var url: URL? {
            return URL(string: urlString)
        }
    }

    struct ResponseInfo: Decodable {
        let status: Int
        let content: ResponseContent
    }

    struct ResponseContent: Decodable {
        let mimeType: String

        // some responses that have length 0 may not include a text field at all
        let text: String?

        var data: Data? {
            return text.flatMap { Data($0.utf8) }
        }
    }
}
