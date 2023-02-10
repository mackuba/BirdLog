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
              let timelineType = timelineType(for: url)
        else {
            return []
        }

        guard entry.response.content.mimeType == "application/json" else {
            return []
        }

        var allTweets: [Tweet] = []

        let jsonDecoder = JSONDecoder()
        let timeline = try jsonDecoder.decode(timelineType, from: entry.response.content.data)

        for instruction in timeline.instructions {
            switch instruction.type {
                case .addEntries:
                    guard let entries = instruction.entries else { continue }

                    let tweets = entries.flatMap { entry in
                        return entry.tweets.compactMap { $0.tweetResults.result?.buildTweet() }
                    }

                    allTweets.append(contentsOf: tweets)

                case .clearCache:
                    continue
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
