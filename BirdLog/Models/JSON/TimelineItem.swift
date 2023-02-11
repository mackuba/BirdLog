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
        let result: TweetData?

        enum CodingKeys: CodingKey {
            case result
        }

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
            }
        }
    }

    struct PartialResult: Decodable {
        enum TypeName: String, Decodable {
            case tweet = "Tweet"
            case tweetWithVisibility = "TweetWithVisibilityResults"
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
        let createdAt: Date
        let fullText: String
        let id: String

        enum CodingKeys: String, CodingKey {
            case createdAt = "created_at"
            case fullText = "full_text"
            case id = "id_str"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.fullText = try container.decode(String.self, forKey: .fullText)
            self.id = try container.decode(String.self, forKey: .id)

            let dateString = try container.decode(String.self, forKey: .createdAt)
            self.createdAt = try TweetDateFormatter.shared.parseDate(from: dateString)
        }
    }
}
