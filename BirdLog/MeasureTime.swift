//
//  MeasureTime.swift
//  BirdLog
//
//  Created by Kuba Suder on 13/04/2023.
//  Licensed under Mozilla Public License 2.0
//

import Foundation

func measureTime<ReturnType>(_ block: () throws -> ReturnType) rethrows -> ReturnType {
    let start = DispatchTime.now()
    let returnValue = try block()
    let end = DispatchTime.now()

    let nano = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nano) / 1_000_000_000

    print("Block duration: \(timeInterval)")

    return returnValue
}
