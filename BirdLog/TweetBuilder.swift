//
//  TweetBuilder.swift
//  BirdLog
//
//  Created by Kuba Suder on 11/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

class TweetBuilder {
    func buildTweet(from data: TimelineItem.TweetData) -> Tweet {
        let author = buildUser(from: data.core.userResults.result)

        let tweet = Tweet(
            id: data.legacy.id,
            text: replaceEntities(in: data.legacy.fullText, from: data.legacy.entities),
            author: author,
            date: data.legacy.createdAt,
            retweetedTweet: buildRetweetedTweet(from: data.legacy.retweetedStatus),
            quotedTweet: buildQuotedTweet(from: data.quotedStatus)
        )

        return tweet
    }

    func replaceEntities(in text: String, from entities: TimelineItem.TweetEntities) -> String {
        return entities.urls.reduce(text) { string, entity in
            string.replacingOccurrences(of: entity.shortenedURL.absoluteString, with: entity.expandedURL.absoluteString)
        }
    }

    func buildUser(from data: TimelineItem.UserResult) -> User {
        return User(
            id: data.restId,
            displayName: data.legacy.name,
            screenName: data.legacy.screenName
        )
    }

    func buildRetweetedTweet(from data: TimelineItem.TweetData?) -> RetweetedTweet? {
        guard let data else { return nil }

        let author = buildUser(from: data.core.userResults.result)

        return RetweetedTweet(
            id: data.legacy.id,
            text: replaceEntities(in: data.legacy.fullText, from: data.legacy.entities),
            author: author,
            date: data.legacy.createdAt,
            quotedTweet: buildQuotedTweet(from: data.quotedStatus)
        )
    }

    func buildQuotedTweet(from data: TimelineItem.TweetData?) -> QuotedTweet? {
        guard let data else { return nil }

        let author = buildUser(from: data.core.userResults.result)

        return QuotedTweet(
            id: data.legacy.id,
            text: replaceEntities(in: data.legacy.fullText, from: data.legacy.entities),
            author: author,
            date: data.legacy.createdAt
        )
    }
}
