//
//  ViewController.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        let builder = TweetBuilder()

        do {
            let data = try Data(contentsOf: url)
            let requests = try harDecoder.decodeRequests(from: data)

            var allTweetData: [TimelineItem.TweetData] = []

            for request in requests {
                let tweetDatas = try timelineDecoder.decodeTweetData(from: request)
                allTweetData.append(contentsOf: tweetDatas)
            }

            let tweets = allTweetData.map { builder.buildTweet(from: $0) }

            let sortedTweets = tweets.sorted { $0.date > $1.date }

            for tweet in sortedTweets {
                let retweet = tweet.retweetedTweet
                let quote = retweet?.quotedTweet ?? tweet.quotedTweet

                print("\(tweet.date) " +
                      (retweet != nil ?
                        "[by @\(tweet.author.screenName)] @\(retweet!.author.screenName): " :
                        "\(tweet.author.screenName): ") +
                      "\"\(retweet?.text ?? tweet.text)\"" +
                      (quote != nil ?
                       "\n  --> @\(quote!.author.screenName): \"\(quote!.text)\""
                        : ""
                      )
                )
            }
        } catch let error {
            print(error)
        }
    }
}
