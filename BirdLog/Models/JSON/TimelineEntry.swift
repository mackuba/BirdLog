//
//  TimelineEntry.swift
//  BirdLog
//
//  Created by Kuba Suder on 11/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

struct TimelineEntry: Decodable {
    let content: Content

    var items: [TimelineItem] {
        if let item = content.itemContent, content.entryType == .item {
            return [item]
        } else if let items = content.items, content.entryType == .module {
            return items.map { $0.item.itemContent }
        } else {
            return []
        }
    }

    var componentType: ComponentType {
        content.clientEventInfo?.component ?? .notSpecified
    }

    struct Content: Decodable {
        let entryType: EntryType

        // some entries like TimelineTimelineCursor, items with empty tweet_results
        // and tweets on user timeline will not contain clientEventInfo
        let clientEventInfo: ClientEventInfo?

        // single tweet entries contain `itemContent`, conversation entries contain `items`
        // (some other entries contain neither)
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
        // normal tweet from someone you follow
        case organicFeedTweet = "suggest_ranked_organic_tweet"

        // tweet in a list timeline
        case organicListTweet = "suggest_organic_list_tweet"

        // user's pinned tweet
        case pinnedTweet = "suggest_pinned_tweet"

        // reply that shows in your timeline
        case extendedReply = "suggest_extended_reply"

        // algorithmic timeline suggested tweets
        case socialContext = "suggest_sc_tweet"                     // X follows
        case socialActivity = "suggest_activity_tweet"              // X liked
        case rankedTimelineTweet = "suggest_ranked_timeline_tweet"

        // promoted tweet (ad)
        case promotedTweet = "suggest_promoted"

        // "Who to follow" block
        case followSuggestions = "suggest_who_to_follow"

        // clientEventInfo block is missing
        case notSpecified

        var isRelevant: Bool {
            switch self {
                case .organicListTweet, .organicFeedTweet, .pinnedTweet, .extendedReply, .socialContext:
                    return true
                default:
                    return false
            }
        }
    }

    struct SubItem: Decodable {
        let item: SubItemData
    }

    struct SubItemData: Decodable {
        let clientEventInfo: ClientEventInfo
        let itemContent: TimelineItem
    }
}
