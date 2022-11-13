//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public struct ConflictingWords: Sendable, Hashable {
    public let word0: String
    public let word1: String
}


public extension BIP39WordList.Validation.WordSimilarity {
    struct SimilarWords: Sendable, Hashable, Comparable, CustomStringConvertible {
        public var word0: String
        public var word1: String
        public var similarity: Double
    
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.similarity < rhs.similarity
        }
    }
}

public extension BIP39WordList.Validation.WordSimilarity.SimilarWords {
    
    var asConflict: ConflictingWords {
        .init(word0: word0, word1: word1)
    }
    
    var description: String {
        """
        "\(word0)" vs "\(word1)" @ \(similarity * 100)%
        """
    }
}
