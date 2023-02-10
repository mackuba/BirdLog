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
