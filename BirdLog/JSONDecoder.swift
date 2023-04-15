//
//  JSONDecoder.swift
//  BirdLog
//
//  Created by Kuba Suder on 15/04/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation
import ZippyJSON

protocol CompatibleJSONDecoder {
    func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: CompatibleJSONDecoder {}
extension ZippyJSONDecoder: CompatibleJSONDecoder {}

func defaultJSONDecoder() -> CompatibleJSONDecoder {
    #if DEBUG
        return JSONDecoder()
    #else
        return ZippyJSONDecoder()
    #endif
}
