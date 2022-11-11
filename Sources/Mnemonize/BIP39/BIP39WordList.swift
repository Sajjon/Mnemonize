//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-01.
//

import Foundation
import Collections


/// A [BIP39][bip] word list in some language.
///
///[bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
public struct BIP39WordList {
    public let words: OrderedSet<String>
    public let language: String
    public static let defaultThreshold: Double = 0.92

    init(
        words: OrderedSet<String>,
        language: String,
        validation: Validation,
        stringSimilarityThreshold: Double = Self.defaultThreshold
    ) throws {
        guard words.count == 2048 else {
            throw Error.expectedExactly2048Words(butGot: words.count)
        }
        
        if
            validation.contains(.smartSectionOfWords),
            !Self.unambiguouslyIdentifiableByFirstFourLetters(words)
        {
            throw Error.wordsAreNotUnambigiouslyIdentifiedByFirstFourLetters
        }
        
        if
            validation.contains(.similarWordsAvoided),
            let similarWords = Self.similarWords(words, maxSimilarityThreshold: stringSimilarityThreshold)
        {
            throw Error.similarWordsFound(similarWords)
        }
        
        if
            validation.contains(.sortedLexicongraphically),
            words.sorted() != words.elements
        {
            throw Error.wordsAreNotLexicongraphicallySorted
        }
       
        self.words = words
        self.language = language
    }
}

public extension BIP39WordList {
    
    struct Validation: OptionSet {
        /// The words follow these rules
        /// * First four letters unambiguously identify the word
        /// *
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
public extension BIP39WordList.Validation {
    
    /// First four letters unambiguously identify the word
    static let smartSectionOfWords      = Self(rawValue: 1 << 0)
    
    /// Similar words avoided: Word pairs like "build" and "built", "woman" and "women", or "quick" and "quickly" ought to be avoided.
    static let similarWordsAvoided      = Self(rawValue: 1 << 1)
    
    /// Sorted lexicongraphically
    static let sortedLexicongraphically = Self(rawValue: 1 << 2)
}

public extension BIP39WordList.Validation {
    static let strict: Self = [.smartSectionOfWords, .similarWordsAvoided, .sortedLexicongraphically]
}

public extension BIP39WordList {
    enum Error: Swift.Error, Equatable {
        case expectedExactly2048Words(butGot: Int)
        case wordsAreNotLexicongraphicallySorted
        case wordsAreNotUnambigiouslyIdentifiedByFirstFourLetters
        case similarWordsFound(SimilarWordsReport)
    }
}

public extension BIP39WordList {
    
    static func unambiguouslyIdentifiableByFirstFourLetters(
        _ words: OrderedSet<String>
    ) -> Bool {
        unambiguouslyIdentifiableByFirst(4, lettersIn: words)
    }
    
    static func unambiguouslyIdentifiableByFirst(
        _ letterCount: Int,
        lettersIn words: OrderedSet<String>
    ) -> Bool {
        Set(words.map {
            $0.prefix(letterCount)
        }).count == words.count
    }
    
    struct SimilarWords: Sendable, Hashable, Comparable {
        public var word0: String
        public var word1: String
        public var similarity: Double
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.similarity < rhs.similarity
        }
    }
    struct SimilarWordsReport: Sendable, Hashable {
        public var similarWords: SimilarWords
        public let maxSimilarityThreshold: Double
        
    }
   
    
    /// Using [`Hamming distance`][alg]
    /// [alg]: https://en.wikipedia.org/wiki/Hamming_distance
    static func similarWords(
        _ words: OrderedSet<String>,
        maxSimilarityThreshold: Double
    ) -> SimilarWordsReport? {
   
        var maxSimilarity = SimilarWords(
            word0: "_",
            word1: "_",
            similarity: .leastNonzeroMagnitude
        )
        var minSimilarity = SimilarWords(
            word0: "_",
            word1: "_",
            similarity: .greatestFiniteMagnitude
        )
        
        var sum: Double = 0
        var wordsChecked = 0
        for index in 0..<(words.count - 1) { // stop at second to last
            for indexOther in (index + 1)..<words.count {
                let word = words[index]
                let other = words[indexOther]
                let similarity = Self.similar(word0: word, word1: other)
                if similarity < minSimilarity {
                    minSimilarity = similarity
                }
                if similarity > maxSimilarity {
                    maxSimilarity = similarity
                }
                sum += similarity.similarity
                wordsChecked += 1
                guard similarity.similarity <= maxSimilarityThreshold else {
                    print("'\(word)' & '\(other)' are too similar (\(similarity.similarity * 100)%)")
                    return .init(
                        similarWords: similarity,
                        maxSimilarityThreshold: maxSimilarityThreshold
                    )
                }
//                if similarity.similarity > 0.5 {
//                    print("'\(word)' ~!~ '\(other)' \(similarity.similarity * 100)%")
//                }
//                print("'\(word)' ~!~ '\(other)' \(similarity.similarity * 100)%")
            }
        }
        let averageSimilarity = sum / Double(wordsChecked)
        print("✅ no words are too similar. Max threshold of: \(maxSimilarityThreshold). averageSimilarity: \(averageSimilarity), Min similarity: \(minSimilarity), max similartiy: \(maxSimilarity)")
        return nil
    }
    
    
    static func similar(
        word0: String,
        word1: String
    ) -> SimilarWords {
        .init(
            word0: word0,
            word1: word1,
            similarity: cyonDistance(
                between: word0,
                and: word1
            )
        )
    }
}


public struct DistanceInput: Sendable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.worthOfFirstChar == rhs.worthOfFirstChar &&
        lhs.sameLengthValueScaling == rhs.sameLengthValueScaling &&
        lhs.diffentLengthValueScaling == rhs.diffentLengthValueScaling &&
        lhs.similarCharacterMultiplier == rhs.similarCharacterMultiplier
        else {
            return false
        }
        guard lhs.similarCharacters.count == rhs.similarCharacters.count else {
            return false
        }
        for index in 0..<lhs.similarCharacters.count {
            let l = lhs.similarCharacters[index]
            let r = rhs.similarCharacters[index]
            guard (l.0 == r.0 && l.1 == r.1) || (l.0 == r.1 && l.1 == r.0) else {
               continue
            }
            return false
        }
        return true
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(worthOfFirstChar)
        hasher.combine(sameLengthValueScaling)
        hasher.combine(diffentLengthValueScaling)
        hasher.combine(similarCharacterMultiplier)
    }
    
    
    public let worthOfFirstChar: Double
    public let sameLengthValueScaling: Double
    public let diffentLengthValueScaling: Double
    public let similarCharacterMultiplier: Double
    public let similarCharacters: [(Character, Character)]

    public init(
        worthOfFirstChar: Double = 0.5,
        sameLengthValueScaling: Double = 0.5,
        diffentLengthValueScaling: Double = 0.5,
        similarCharacterMultiplier: Double = 0.4,
        similarCharacters: [(Character, Character)] = [
            ("a", "e"),
            ("d", "t"),
        ]
    ) {
        self.worthOfFirstChar = worthOfFirstChar
        self.sameLengthValueScaling = sameLengthValueScaling
        self.diffentLengthValueScaling = diffentLengthValueScaling
        self.similarCharacterMultiplier = similarCharacterMultiplier
        self.similarCharacters = similarCharacters
    }
    public static let `default` = Self()
}

public func cyonDistance(
    between word0: String,
    and word1: String,
    input: DistanceInput = .default
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
        } else if input.similarCharacters
            .contains(where: {
                ($0.0 == char0 && $0.1 == char1) ||
                ($0.0 == char1 && $0.1 == char0)
            })
        {
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
