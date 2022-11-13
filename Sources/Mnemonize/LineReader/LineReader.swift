//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-12.
//

import Foundation

public struct LineReader: Sendable {
    public var read: ReadNewLine
    public init(read: @escaping ReadNewLine) {
        self.read = read
    }
}

public extension LineReader {
    typealias ReadNewLine = @Sendable (String, Int) throws -> ReadLine
}

public extension LineReader {
    static let liveValue = Self(read: {
        ReadLine(lineFromCorpus: $0, positionInCorpus: $1)
    })
}
