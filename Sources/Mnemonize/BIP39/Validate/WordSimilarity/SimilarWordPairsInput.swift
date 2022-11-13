//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public extension BIP39WordList.Validation.WordSimilarity {
    struct SimilarWordPairsInput: Sendable, Hashable {
        
        public let worthOfFirstChar: Double
        public let sameLengthValueScaling: Double
        public let diffentLengthValueScaling: Double
        public let similarCharacterMultiplier: Double
        public let similarCharacters: SimilarCharacters
        
        public init(
            worthOfFirstChar: Double = 0.5,
            sameLengthValueScaling: Double = 0.5,
            diffentLengthValueScaling: Double = 0.5,
            similarCharacterMultiplier: Double = 0.4,
            similarCharacters: SimilarCharacters = .english
        ) {
            self.worthOfFirstChar = worthOfFirstChar
            self.sameLengthValueScaling = sameLengthValueScaling
            self.diffentLengthValueScaling = diffentLengthValueScaling
            self.similarCharacterMultiplier = similarCharacterMultiplier
            self.similarCharacters = similarCharacters
        }
    }
}

public extension BIP39WordList.Validation.WordSimilarity.SimilarWordPairsInput {
    static let englishDefault = Self()
}
