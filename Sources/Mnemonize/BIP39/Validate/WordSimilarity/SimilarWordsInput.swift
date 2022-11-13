//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation


public extension BIP39WordList.Validation.WordSimilarity {
    struct Input: Sendable, Hashable {
        
        public let threshold: Double
        public let similarWordPairsInput: SimilarWordPairsInput
       
        public init(
            threshold: Double = Self.defaultThreshold,
            similarWordPairsInput: SimilarWordPairsInput = .englishDefault
        ) {
            self.threshold = threshold
            self.similarWordPairsInput = similarWordPairsInput
        }
    }
}

public extension BIP39WordList.Validation.WordSimilarity.Input {
    
    static let defaultThreshold: Double = 0.92
   
    /// Strict according to [`BIP39`][bip], which means that similar words are avoided:
    ///
    /// "word pairs like "build" and "built", "woman" and "women", or "quick" and "quickly"
    /// not only make remembering the sentence difficult but are also more error
    /// prone and more difficult to guess"
    ///
    /// [bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    static let englishStrict = Self(
        threshold: Self.defaultThreshold,
        similarWordPairsInput: .englishDefault
    )
    
    static let `default`: Self = .englishStrict
}
