//
//  ViewController.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Cocoa

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
                do {
                    let importer = HARImport(context: self.managedObjectContext)
                    try importer.importTweets(from: url)
                } catch let error {
                    print(error)
                }
            }
        }
    }

    @IBAction func exportToJSON(_ sender: Any) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Tweets.json"
        panel.isExtensionHidden = false

        panel.beginSheetModal(for: self.view.window!) { response in
            if response == .OK, let url = panel.url {
                do {
                    let exporter = TweetExporter(context: self.managedObjectContext)
                    try exporter.exportJSON(to: url)
                } catch let error {
                    print(error)
                }
            }
        }
    }
}
