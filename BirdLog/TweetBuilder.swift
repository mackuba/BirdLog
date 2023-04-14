//
//  TweetBuilder.swift
//  BirdLog
//
//  Created by Kuba Suder on 11/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import CoreData
import Foundation

private let sourceStripRegexp = try! NSRegularExpression(pattern: "</?a[^>]*>")

class TweetBuilder {
    let context: NSManagedObjectContext
    var newTweets: [String:Tweet] = [:]
    var newUsers: [String:User] = [:]

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func buildTweet(from data: TimelineItem.TweetData) throws -> Tweet {
        let tweetId = data.legacy.id

        if let newTweet = newTweets[tweetId] {
            return newTweet
        }

        let request = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [tweetId])
        request.fetchLimit = 1
        request.includesPendingChanges = false

        let results = try context.fetch(request)

        if let existing = results.first {
            return existing
        }

        let tweet = Tweet(context: context)

        tweet.id = tweetId
        tweet.date = data.legacy.createdAt
        tweet.author = try buildUser(from: data.core.userResults.result)

        if let retweetData = data.legacy.retweetedStatus {
            tweet.retweetedTweet = try buildTweet(from: retweetData)
        } else {
            tweet.text = replaceEntities(in: data.legacy.fullText, from: data.legacy.entities)
        }

        if let quoteData = data.quotedStatus {
            tweet.quotedTweet = try buildTweet(from: quoteData)
        }

        if let source = data.source {
            tweet.source = sourceStripRegexp.stringByReplacingMatches(
                in: source,
                range: NSRange(location: 0, length: (source as NSString).length),
                withTemplate: ""
            )
        }

        newTweets[tweetId] = tweet

        return tweet
    }

    func replaceEntities(in text: String, from entities: TimelineItem.TweetEntities) -> String {
        return entities.urls.reduce(text) { string, entity in
            string.replacingOccurrences(of: entity.shortenedURL.absoluteString, with: entity.expandedURL.absoluteString)
        }
    }

    func buildUser(from data: TimelineItem.UserResult) throws -> User {
        let userId = data.restId

        if let newUser = newUsers[userId] {
            return newUser
        }

        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [userId])
        request.fetchLimit = 1
        request.includesPendingChanges = false

        let results = try context.fetch(request)

        if let existing = results.first {
            return existing
        }

        let user = User(context: context)
        user.id = userId
        user.displayName = data.legacy.name
        user.screenName = data.legacy.screenName

        newUsers[userId] = user

        return user
    }
}
