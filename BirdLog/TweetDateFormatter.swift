//
//  TweetDateFormatter.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

class TweetDateFormatter: DateFormatter {
    struct InvalidDateError: LocalizedError {
        let dateString: String

        var errorDescription: String? {
            return "Invalid date: \(dateString)"
        }
    }

    static let shared = TweetDateFormatter()

    override init() {
        super.init()

        self.dateFormat = "E MMM dd HH:mm:ss Z y"
        self.locale = Locale(identifier: "en_US_POSIX")
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func parseDate(from string: String) throws -> Date {
        guard let date = self.date(from: string) else {
            throw InvalidDateError(dateString: string)
        }

        return date
    }
}
