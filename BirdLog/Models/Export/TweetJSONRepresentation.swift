//
//  TweetJSONRepresentation.swift
//  BirdLog
//
//  Created by Kuba Suder on 15/04/2023.
//  Licensed under Mozilla Public License 2.0
//
//

import Foundation

struct TweetJSONRepresentation: Encodable {
    let tweet: Tweet

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case date
        case author
        case retweet
        case quote
        case favorites
        case retweets
        case replies
        case quotes
    }

    init(_ tweet: Tweet) {
        self.tweet = tweet
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tweet.id!, forKey: .id)
        try container.encode(tweet.date!, forKey: .date)
        try container.encode(Author(tweet.author!), forKey: .author)

        if let retweet = tweet.retweetedTweet {
            try container.encode(TweetJSONRepresentation(retweet), forKey: .retweet)
        } else {
            try container.encode(tweet.text, forKey: .text)

            if let quote = tweet.quotedTweet {
                try container.encode(TweetJSONRepresentation(quote), forKey: .quote)
            }
        }

        try container.encode(tweet.favoriteCount, forKey: .favorites)
        try container.encode(tweet.retweetCount, forKey: .retweets)
        try container.encode(tweet.replyCount, forKey: .replies)
        try container.encode(tweet.quoteCount, forKey: .quotes)
    }

    struct Author: Encodable {
        let user: User

        enum CodingKeys: String, CodingKey {
            case id
            case screenName
            case name
        }

        init(_ user: User) {
            self.user = user
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(user.id!, forKey: .id)
            try container.encode(user.screenName!, forKey: .screenName)
            try container.encode(user.displayName, forKey: .name)
        }
    }
}
