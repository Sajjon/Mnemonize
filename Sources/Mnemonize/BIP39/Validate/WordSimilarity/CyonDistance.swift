//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public func cyonDistance(
    between word0: String,
    and word1: String,
    input: BIP39WordList.Validation.WordSimilarity.SimilarWordPairsInput = .englishDefault
) -> Double {
    guard !word0.isEmpty else { return 0 }
    guard !word1.isEmpty else { return 0 }
    guard word0 != word1 else { return 1 }
    
    let lengths = [word0, word1].map(\.count)
    let shortestLength = lengths.min()!
    let longestLength = lengths.max()!
    
    /// Between 0-1.0
    var similarity: Double = 0
    var positionWorth = input.worthOfFirstChar
    for offset in 0..<shortestLength {
        let char0 = word0[String.Index(utf16Offset: offset, in: word0)]
        let char1 = word1[String.Index(utf16Offset: offset, in: word1)]
        if char0 == char1 {
            similarity += positionWorth
        } else if input.similarCharacters.contains((char0, char1)) {
            similarity += (input.similarCharacterMultiplier * positionWorth)
        } else {
            similarity -= positionWorth
        }
        
        positionWorth *= input.sameLengthValueScaling
    }
    let lengthDelta = longestLength - shortestLength
    
    for _ in 0..<lengthDelta {
        similarity -= positionWorth
        positionWorth *= input.diffentLengthValueScaling
    }
    guard similarity >= 0 else { return 0.0 }

    assert(similarity <= 1.0)

    return similarity
}
