//
//  ViewController.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Cocoa
import OSLog

import ExtrasJSON
import IkigaJSON
import YAJLO
import ZippyJSON

private let log = Logger()

class ViewController: NSViewController {

    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
    }

    @IBAction func openDocument(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.message = "Open a HAR archive to import:"
        panel.allowedFileTypes = ["har"]

        panel.beginSheetModal(for: self.view.window!) { response in
            if response == .OK, let url = panel.url {
                self.importHARArchive(url: url)
            }
        }
    }

    func importHARArchive(url: URL) {
        let harDecoder = HARDecoder()
        let timelineDecoder = TimelineDecoder()
        let builder = TweetBuilder(context: managedObjectContext)

        do {
            log.debug("Reading file...")
            let data = try Data(contentsOf: url)

            log.debug("Decoding HAR...")

            log.debug("JSONDecoder (as models):")
            let requests = try measureTime { try harDecoder.decodeRequests(from: data) }

            log.debug("JSONSerialization (as dict):")
            let _ = try measureTime { try JSONSerialization.jsonObject(with: data) }

            log.debug("YAJL (as dict):")
            let _ = try measureTime { try YAJLDocument(data: data, parserOptions: .none).root }

            log.debug("Zippy (as models):")
            let _ = try measureTime { try ZippyJSONDecoder().decode(HARArchive.self, from: data).log.entries }

            log.debug("Ikiga (as models):")
            let _ = try measureTime { try IkigaJSONDecoder().decode(HARArchive.self, from: data).log.entries }

            log.debug("ExtrasJSON (as models):")
            let _ = try measureTime { try XJSONDecoder().decode(HARArchive.self, from: data).log.entries }

            var allTweetData: [TimelineItem.TweetData] = []

            log.debug("Decoding tweet JSON...")

            log.debug("JSONDecoder:")
            try measureTime {
                for request in requests {
                    let tweetDatas = try timelineDecoder.decodeTweetData(from: request, using: JSONDecoder())
                    allTweetData.append(contentsOf: tweetDatas)
                }
            }

            log.debug("Zippy:")
            try measureTime {
                for request in requests {
                    let tweetDatas = try timelineDecoder.decodeTweetData(from: request, using: ZippyJSONDecoder())
                    allTweetData.append(contentsOf: tweetDatas)
                }
            }

            log.debug("Ikiga:")
            try measureTime {
                for request in requests {
                    let tweetDatas = try timelineDecoder.decodeTweetData(from: request, using: IkigaJSONDecoder())
                    allTweetData.append(contentsOf: tweetDatas)
                }
            }

            log.debug("ExtrasJSON:")
            try measureTime {
                for request in requests {
                    let tweetDatas = try timelineDecoder.decodeTweetData(from: request, using: XJSONDecoder())
                    allTweetData.append(contentsOf: tweetDatas)
                }
            }

            log.debug("Building tweets...")
            let tweets = try allTweetData.map { try builder.buildTweet(from: $0) }

            let sortedTweets = tweets.sorted { $0.date! > $1.date! }

            log.debug("Saving managed context to the store...")
            try managedObjectContext.save()

            log.debug("Done ✓")

            /*for tweet in sortedTweets {
                let retweet = tweet.retweetedTweet
                let quote = retweet?.quotedTweet ?? tweet.quotedTweet

                print("\(tweet.date!) " +
                      (retweet != nil ?
                        "[by @\(tweet.author?.screenName)] @\(retweet!.author?.screenName): " :
                        "\(tweet.author?.screenName): ") +
                      "\"\(retweet?.text ?? tweet.text)\"" +
                      (quote != nil ?
                       "\n  --> @\(quote!.author?.screenName): \"\(quote!.text)\""
                        : ""
                      )
                )
            }*/
        } catch let error {
            print(error)
        }
    }
}
