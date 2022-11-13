//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public extension BIP39WordList.Validation.WordSimilarity {
    struct Report: Sendable, Hashable {
        public internal(set) var similarWords: SimilarWords
        public let input: Input
        
        public init(similarWords: SimilarWords, input: Input) {
            self.similarWords = similarWords
            self.input = input
        }
    }
}

public extension BIP39WordList.Validation.WordSimilarity.Report {
    var conflictingWords: ConflictingWords {
        similarWords.asConflict
    }
}
