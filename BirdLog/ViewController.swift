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

        do {
            let data = try Data(contentsOf: url)
            let requests = try harDecoder.decodeRequests(from: data)

            var tweetMap: [String:Tweet] = [:]

            for request in requests {
                let tweets = try timelineDecoder.decodeTweets(from: request)
                for tweet in tweets {
                    tweetMap[tweet.id] = tweet
                }
            }

            let sortedTweets = tweetMap.values.sorted { $0.date > $1.date }

            for tweet in sortedTweets {
                print("\(tweet.date) " +
                      (tweet.retweetedTweet != nil ?
                        "[by @\(tweet.author.screenName)] @\(tweet.retweetedTweet!.author.screenName): " :
                        "\(tweet.author.screenName): ") +
                      "\"\(tweet.retweetedTweet?.text ?? tweet.text)\"")
            }
        } catch let error {
            print(error)
        }
    }
}
