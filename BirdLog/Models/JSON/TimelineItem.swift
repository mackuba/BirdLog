//
//  TimelineItem.swift
//  BirdLog
//
//  Created by Kuba Suder on 11/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

struct TimelineItem: Decodable {
    let itemType: ItemType

    // timeline may contain e.g. "Who to follow" blocks with items that include
    // user_results instead of tweet_results
    let tweetResults: TweetResults?

    enum CodingKeys: String, CodingKey {
        case itemType
        case tweetResults = "tweet_results"
    }

    enum ItemType: String, Decodable {
        case tweet = "TimelineTweet"
        case user = "TimelineUser"
    }

    struct TweetResults: Decodable {
        // there are sometimes empty timeline items with tweet_results that is just {}
        let result: TweetData?

        enum CodingKeys: CodingKey {
            case result
        }

        // for tweets with e.g. restricted replying, the result block will have
        // typename = TweetWithVisibilityResults and then all data below is
        // wrapped in an additional `tweet` subobject instead of directly under `result`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard let partial = try container.decodeIfPresent(PartialResult.self, forKey: .result) else {
                result = nil
                return
            }

            switch partial.typeName {
                case .tweet:
                    result = try container.decode(TweetData.self, forKey: .result)

                case .tweetWithVisibility:
                    let wrapper = try container.decode(TweetWithVisibilityData.self, forKey: .result)
                    result = wrapper.tweet

                case .unavailableTweet:
                    result = nil
                    return
            }
        }
    }

    struct PartialResult: Decodable {
        enum TypeName: String, Decodable {
            case tweet = "Tweet"
            case tweetWithVisibility = "TweetWithVisibilityResults"
            case unavailableTweet = "TweetUnavailable"
        }

        let typeName: TypeName

        enum CodingKeys: String, CodingKey {
            case typeName = "__typename"
        }
    }

    struct TweetWithVisibilityData: Decodable {
        let tweet: TweetData
    }

    struct TweetData: Decodable {
        let core: CoreData
        let legacy: LegacyTweetData

        private let quotedStatuses: [TweetResults]

        var quotedStatus: TweetData? {
            quotedStatuses.first?.result
        }

        enum CodingKeys: String, CodingKey {
            case core
            case legacy
            case quotedStatuses = "quoted_status_result"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.core = try container.decode(CoreData.self, forKey: .core)
            self.legacy = try container.decode(LegacyTweetData.self, forKey: .legacy)

            let quotedStatus = try container.decodeIfPresent(TweetResults.self, forKey: .quotedStatuses)
            self.quotedStatuses = [quotedStatus].compactMap { $0 }
        }
    }

    struct CoreData: Decodable {
        let userResults: UserResults

        enum CodingKeys: String, CodingKey {
            case userResults = "user_results"
        }
    }

    struct UserResults: Decodable {
        let result: UserResult
    }

    struct UserResult: Decodable {
        let restId: String
        let legacy: LegacyUserData

        enum CodingKeys: String, CodingKey {
            case restId = "rest_id"
            case legacy
        }
    }

    struct LegacyUserData: Decodable {
        let screenName: String
        let name: String

        enum CodingKeys: String, CodingKey {
            case screenName = "screen_name"
            case name
        }
    }

    struct LegacyTweetData: Decodable {
        let id: String
        let createdAt: Date
        let fullText: String
        let entities: TweetEntities

        private let retweetedStatuses: [TweetResults]

        var retweetedStatus: TweetData? {
            retweetedStatuses.first?.result
        }

        enum CodingKeys: String, CodingKey {
            case id = "id_str"
            case createdAt = "created_at"
            case fullText = "full_text"
            case retweetedStatus = "retweeted_status_result"
            case entities = "entities"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.fullText = try container.decode(String.self, forKey: .fullText)
            self.id = try container.decode(String.self, forKey: .id)

            let dateString = try container.decode(String.self, forKey: .createdAt)
            self.createdAt = try TweetDateFormatter.shared.parseDate(from: dateString)

            let retweetedStatus = try container.decodeIfPresent(TweetResults.self, forKey: .retweetedStatus)
            self.retweetedStatuses = [retweetedStatus].compactMap { $0 }

            self.entities = try container.decode(TweetEntities.self, forKey: .entities)
        }
    }

    struct TweetEntities: Decodable {
        let urls: [URLEntity]
    }

    struct URLEntity: Decodable {
        let expandedURL: URL
        let shortenedURL: URL

        struct InvalidURL: LocalizedError {
            let url: String

            var errorDescription: String? {
                return "Invalid URL: \(url)"
            }
        }

        enum CodingKeys: String, CodingKey {
            case expandedURL = "expanded_url"
            case shortenedURL = "url"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let expandedStr = try container.decode(String.self, forKey: .expandedURL)
            guard let expandedURL = URL(string: expandedStr) else { throw InvalidURL(url: expandedStr) }
            self.expandedURL = expandedURL

            let shortenedStr = try container.decode(String.self, forKey: .shortenedURL)
            guard let shortenedURL = URL(string: shortenedStr) else { throw InvalidURL(url: shortenedStr) }
            self.shortenedURL = shortenedURL
        }
    }
}
