//
//  Tweet.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

struct Tweet: Codable {
    let id: String
    let text: String
    let author: User
    let date: Date
    let retweetedTweet: RetweetedTweet?
    let quotedTweet: QuotedTweet?
}

struct QuotedTweet: Codable {
    let id: String
    let text: String
    let author: User
    let date: Date
}

struct RetweetedTweet: Codable {
    let id: String
    let text: String
    let author: User
    let date: Date
    let quotedTweet: QuotedTweet?
}
