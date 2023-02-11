//
//  Timelines.swift
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

    // instructions like TimelineClearCache will not contain an entries field
    let entries: [TimelineEntry]?

    enum InstructionType: String, Decodable {
        case addEntries = "TimelineAddEntries"
        case clearCache = "TimelineClearCache"
    }
}
