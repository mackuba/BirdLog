//
//  TweetBuilder.swift
//  BirdLog
//
//  Created by Kuba Suder on 11/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import CoreData
import Foundation

class TweetBuilder {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func buildTweet(from data: TimelineItem.TweetData) throws -> Tweet {
        let tweetId = data.legacy.id

        let tweet = Tweet(context: context)

        tweet.id = tweetId
        tweet.date = data.legacy.createdAt
        tweet.text = replaceEntities(in: data.legacy.fullText, from: data.legacy.entities)
        tweet.author = try buildUser(from: data.core.userResults.result)

        if let retweetData = data.legacy.retweetedStatus {
            tweet.retweetedTweet = try buildTweet(from: retweetData)
        }

        if let quoteData = data.quotedStatus {
            tweet.quotedTweet = try buildTweet(from: quoteData)
        }

        return tweet
    }

    func replaceEntities(in text: String, from entities: TimelineItem.TweetEntities) -> String {
        return entities.urls.reduce(text) { string, entity in
            string.replacingOccurrences(of: entity.shortenedURL.absoluteString, with: entity.expandedURL.absoluteString)
        }
    }

    func buildUser(from data: TimelineItem.UserResult) throws -> User {
        let userId = data.restId

        let user = User(context: context)
        user.id = userId
        user.displayName = data.legacy.name
        user.screenName = data.legacy.screenName
        return user
    }
}
