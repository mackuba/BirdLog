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

        let retweetedTweet = data.legacy.retweetedStatus.flatMap { rt in
            let rtAuthor = buildUser(from: rt.core.userResults.result)

            return RetweetedTweet(
                id: rt.legacy.id,
                text: rt.legacy.fullText,
                author: rtAuthor,
                date: rt.legacy.createdAt
            )
        }

        let tweet = Tweet(
            id: data.legacy.id,
            text: data.legacy.fullText,
            author: author,
            date: data.legacy.createdAt,
            retweetedTweet: retweetedTweet
        )

        return tweet
    }

    func buildUser(from data: TimelineItem.UserResult) -> User {
        return User(
            id: data.restId,
            displayName: data.legacy.name,
            screenName: data.legacy.screenName
        )
    }
}
