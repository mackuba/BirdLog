//
//  TimelineDecoder.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

class TimelineDecoder {
    func decodeTweets(from entry: HARArchive.Entry) throws -> [Tweet] {
        guard entry.request.urlString.hasPrefix("https://api.twitter.com/graphql/"),
              entry.request.method == "GET",
              entry.response.status == 200,
              let url = entry.request.url,
              let timelineType = timelineType(for: url),
              let responseData = entry.response.content.data
        else {
            return []
        }

        guard entry.response.content.mimeType == "application/json" else {
            return []
        }

        var allTweets: [Tweet] = []

        let jsonDecoder = JSONDecoder()
        let builder = TweetBuilder()
        let timeline = try jsonDecoder.decode(timelineType, from: responseData)

        for instruction in timeline.instructions {
            let entries = instruction.allEntries.filter { $0.componentType.isRelevant }

            for entry in entries {
                let timelineItems = entry.items.filter({ $0.itemType == .tweet })
                let tweetDatas = timelineItems.compactMap({ $0.tweetResults?.result })
                let tweets = tweetDatas.map { builder.buildTweet(from: $0) }
                allTweets.append(contentsOf: tweets)
            }
        }

        return allTweets
    }

    func timelineType(for url: URL) -> Timeline.Type? {
        guard let endpoint = url.pathComponents.last else { return nil }

        switch endpoint {
            case "HomeLatestTimeline", "HomeTimeline":
                return MainTimelineJSON.self

            case "ListLatestTweetsTimeline":
                return ListTimelineJSON.self

            case "UserTweets":
                return UserTimelineJSON.self

            default:
                return nil
        }
    }
}
