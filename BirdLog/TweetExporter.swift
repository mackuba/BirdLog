//
//  TweetExporter.swift
//  BirdLog
//
//  Created by Kuba Suder on 15/04/2023.
//  Licensed under Mozilla Public License 2.0
//

import CoreData
import Foundation

class TweetExporter {
    let context: NSManagedObjectContext

    var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        return encoder
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getTweets() throws -> [Tweet] {
        let request = Tweet.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.relationshipKeyPathsForPrefetching = [
            "author", "retweetedTweet", "quotedTweet", "retweetedTweet.quotedTweet"
        ]

        return try context.fetch(request)
    }

    func exportJSON(to file: URL) throws {
        let tweets = try getTweets().map { TweetJSONRepresentation($0) }
        let data = try jsonEncoder.encode(tweets)
        try data.write(to: file)
    }
}
