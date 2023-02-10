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
        let userData = data.core.userResults.result

        let author = User(
            id: userData.restId,
            displayName: userData.legacy.name,
            screenName: userData.legacy.screenName
        )

        let tweet = Tweet(
            id: data.legacy.id,
            text: data.legacy.fullText,
            author: author,
            date: data.legacy.createdAt
        )

        return tweet
    }
}
