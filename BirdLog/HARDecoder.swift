//
//  HARDecoder.swift
//  BirdLog
//
//  Created by Kuba Suder on 10/02/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

class HARDecoder {
    let jsonDecoder: CompatibleJSONDecoder

    init(jsonDecoder: CompatibleJSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }

    func decodeRequests(from archive: Data) throws -> [HARArchive.Entry] {
        let harArchive = try jsonDecoder.decode(HARArchive.self, from: archive)
        return harArchive.log.entries
    }
}
