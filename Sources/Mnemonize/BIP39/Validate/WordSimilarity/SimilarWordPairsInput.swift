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
        public let correlatedCharactersSet: CorrelatedCharactersSet
        
        public init(
            worthOfFirstChar: Double = 0.5,
            sameLengthValueScaling: Double = 0.5,
            diffentLengthValueScaling: Double = 0.5,
            correlatedCharactersSet: CorrelatedCharactersSet = .english
        ) {
            self.worthOfFirstChar = worthOfFirstChar
            self.sameLengthValueScaling = sameLengthValueScaling
            self.diffentLengthValueScaling = diffentLengthValueScaling
            self.correlatedCharactersSet = correlatedCharactersSet
        }
    }
}

public extension BIP39WordList.Validation.WordSimilarity.SimilarWordPairsInput {
    static let englishDefault = Self()
}
