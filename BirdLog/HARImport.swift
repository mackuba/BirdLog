//
//  HARImport.swift
//  BirdLog
//
//  Created by Kuba Suder on 16/04/2023.
//  Licensed under Mozilla Public License 2.0
//

import CoreData
import Foundation
import OSLog

private let log = Logger()

class HARImport {
    let managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    func importTweets(from url: URL) throws {
        let jsonDecoder = defaultJSONDecoder()
        let harDecoder = HARDecoder(jsonDecoder: jsonDecoder)
        let timelineDecoder = TimelineDecoder(jsonDecoder: jsonDecoder)
        let builder = TweetBuilder(context: managedObjectContext)

        log.debug("Reading file...")
        let data = try Data(contentsOf: url)

        log.debug("Decoding HAR...")
        let requests = try harDecoder.decodeRequests(from: data)

        var allTweetData: [TimelineItem.TweetData] = []

        log.debug("Decoding tweet JSON...")
        for request in requests {
            let tweetDatas = try timelineDecoder.decodeTweetData(from: request)
            allTweetData.append(contentsOf: tweetDatas)
        }

        log.debug("Building tweets...")
        let tweets = try allTweetData.map { try builder.buildTweet(from: $0) }

        let sortedTweets = tweets.sorted { $0.date! > $1.date! }

        log.debug("Saving managed context to the store...")
        try managedObjectContext.save()

        log.debug("Done ✓")
    }
}
