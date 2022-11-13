//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-12.
//

import Foundation

/// A read, but not yet parsed line. Read from the corpus.
public struct ReadLine: Sendable, Hashable, Codable, CustomStringConvertible {

    private let l: String
    private let p: Int

    init(lineFromCorpus: String, positionInCorpus: Int) {
        l = lineFromCorpus
        p = positionInCorpus
    }
}

public extension ReadLine {
    var lineFromCorpus: String { l }
    var positionInCorpus: Int { p }
}

// MARK: CustomStringConvertible
public extension ReadLine {
    var description: String { lineFromCorpus }
}
