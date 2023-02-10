//
//  TimelineJSON.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

protocol Timeline: Decodable {
    var instructions: [TimelineInstruction] { get }
}

struct MainTimelineJSON: Decodable, Timeline {
    let data: DataSection

    var instructions: [TimelineInstruction] {
        return data.home.urtSection.instructions
    }

    struct DataSection: Decodable {
        let home: HomeData
    }

    struct HomeData: Decodable {
        let urtSection: UrtSection

        enum CodingKeys: String, CodingKey {
            case urtSection = "home_timeline_urt"
        }
    }

    struct UrtSection: Decodable {
        let instructions: [TimelineInstruction]
    }
}

struct ListTimelineJSON: Decodable, Timeline {
    let data: DataSection

    var instructions: [TimelineInstruction] {
        return data.list.tweetsTimeline.timeline.instructions
    }

    struct DataSection: Decodable {
        let list: ListData
    }

    struct ListData: Decodable {
        let tweetsTimeline: TweetsTimeline

        enum CodingKeys: String, CodingKey {
            case tweetsTimeline = "tweets_timeline"
        }
    }

    struct TweetsTimeline: Decodable {
        let timeline: ActualTimeline
    }

    struct ActualTimeline: Decodable {
        let instructions: [TimelineInstruction]
    }
}

struct UserTimelineJSON: Decodable, Timeline {
    let data: DataSection

    var instructions: [TimelineInstruction] {
        return data.user.result.timelineV2.timeline.instructions
    }

    struct DataSection: Decodable {
        let user: UserData
    }

    struct UserData: Decodable {
        let result: Result
    }

    struct Result: Decodable {
        let timelineV2: TimelineV2

        enum CodingKeys: String, CodingKey {
            case timelineV2 = "timeline_v2"
        }
    }

    struct TimelineV2: Decodable {
        let timeline: ActualTimeline
    }

    struct ActualTimeline: Decodable {
        let instructions: [TimelineInstruction]
    }
}

struct TimelineInstruction: Decodable {
    let type: InstructionType
    let entries: [TimelineEntry]?

    enum InstructionType: String, Decodable {
        case addEntries = "TimelineAddEntries"
        case clearCache = "TimelineClearCache"
    }
}

struct TimelineEntry: Decodable {
    let content: Content

    var tweets: [TimelineItem] {
        if let item = content.itemContent, content.entryType == .item {
            return [item]
        } else if let items = content.items, content.entryType == .module {
            return items.map { $0.item.itemContent }
        } else {
            return []
        }
    }

    struct Content: Decodable {
        let entryType: EntryType
        let clientEventInfo: ClientEventInfo?
        let itemContent: TimelineItem?
        let items: [SubItem]?
    }

    enum EntryType: String, Decodable {
        case item = "TimelineTimelineItem"
        case module = "TimelineTimelineModule"
        case cursor = "TimelineTimelineCursor"
    }

    struct ClientEventInfo: Decodable {
        let component: ComponentType
    }

    enum ComponentType: String, Decodable {
        case organicFeedTweet = "suggest_ranked_organic_tweet"
        case organicListTweet = "suggest_organic_list_tweet"
        case promotedTweet = "suggest_promoted"
    }

    struct SubItem: Decodable {
        let item: SubItemData
    }

    struct SubItemData: Decodable {
        let clientEventInfo: ClientEventInfo
        let itemContent: TimelineItem
    }
}

struct TimelineItem: Decodable {
    let itemType: ItemType
    let tweetResults: TweetResults

    enum CodingKeys: String, CodingKey {
        case itemType
        case tweetResults = "tweet_results"
    }

    enum ItemType: String, Decodable {
        case tweet = "TimelineTweet"
    }

    struct TweetResults: Decodable {
        let result: TweetData?

        enum CodingKeys: CodingKey {
            case result
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

    struct LegacyUserData: Decodable {
        let screenName: String
        let name: String

        enum CodingKeys: String, CodingKey {
            case screenName = "screen_name"
            case name
        }
    }

    struct TweetWithVisibilityData: Decodable {
        let tweet: TweetData
    }

    struct TweetData: Decodable {
        let core: CoreData
        let legacy: LegacyTweetData

        func buildTweet() -> Tweet {
            let userData = core.userResults.result

            let author = User(
                id: userData.restId,
                displayName: userData.legacy.name,
                screenName: userData.legacy.screenName
            )

            let tweet = Tweet(
                id: legacy.id,
                text: legacy.fullText,
                author: author,
                date: legacy.createdAt
            )

            return tweet
        }
    }
}
