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
    

    init(
        words: OrderedSet<String>,
        language: String,
        validation: Validation
    ) throws {
        guard words.count == 2048 else {
            throw Error.expectedExactly2048Words(butGot: words.count)
        }
        
        if let input = validation.unambiguouslyIdentifiableInput,
           !Self.unambiguouslyIdentifiableByFirst(n: input, words)
        {
            throw Error.wordsAreNotUnambigiouslyIdentifiedByFirstFourLetters
        }
        
        if let input = validation.similarWordsDetectionInput,
           let similarWords = Self.similarWords(words, input: input)
        {
            throw Error.similarWordsFound(similarWords)
        }
        
        if let input = validation.sorting,
           Self.areSorted(words: words, input: input)
        {
            throw Error.wordsAreNotLexicongraphicallySorted
        }
       
        self.words = words
        self.language = language
    }
}

public extension BIP39WordList {
    
    static func areSorted(words: OrderedSet<String>, input: SortingInput) -> Bool {
        input.sort(words) != words.elements
    }
    
    struct Validation {
        public let unambiguouslyIdentifiableInput: UnambiguouslyIdentifiableInput?
        public let similarWordsDetectionInput: SimilarWordsInput?
        public let sorting: SortingInput?
    }
}
public struct UnambiguouslyIdentifiableInput {
    public let charCount: Int
    
    /// Strict according to [`BIP39`][bip]:
    ///
    /// "the wordlist is created in such a way that it's enough to type the **first four** letters to unambiguously identify the word"
    ///
    /// [bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    public static let strict = Self(charCount: 4)
    
}
public struct SortingInput {
    
    public let sort: (OrderedSet<String>) -> [String]
    
    public static let lexicongraphically = Self(sort: { $0.sorted() })
    
    /// Strict according to [`BIP39`][bip]:
    ///
    /// "the wordlist is sorted which allows for more efficient lookup of the code words"
    ///
    /// [bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    public static let strict: Self = .lexicongraphically
}

public extension BIP39WordList.Validation {
    
    static let englishStrict = Self(
        unambiguouslyIdentifiableInput: .strict,
        similarWordsDetectionInput: .englishStrict,
        sorting: .strict
    )
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
    
    static func unambiguouslyIdentifiableByFirst(
        n input: UnambiguouslyIdentifiableInput,
        _ words: OrderedSet<String>
    ) -> Bool {
        unambiguouslyIdentifiableByFirst(input.charCount, lettersIn: words)
    }
    
    static func unambiguouslyIdentifiableByFirst(
        _ letterCount: Int,
        lettersIn words: OrderedSet<String>
    ) -> Bool {
        Set(words.map {
            $0.prefix(letterCount)
        }).count == words.count
    }
    
    static func similarWords(
        _ words: OrderedSet<String>,
        input: SimilarWordsInput
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
                guard similarity.similarity <= input.threshold else {
                    print("'\(word)' & '\(other)' are too similar (\(similarity.similarity * 100)%)")
                    return .init(
                        similarWords: similarity,
                        input: input
                    )
                }
//                if similarity.similarity > 0.5 {
//                    print("'\(word)' ~!~ '\(other)' \(similarity.similarity * 100)%")
//                }
//                print("'\(word)' ~!~ '\(other)' \(similarity.similarity * 100)%")
            }
        }
        let averageSimilarity = sum / Double(wordsChecked)
        print("✅ no words are too similar. Max threshold of: \(input.threshold). averageSimilarity: \(averageSimilarity), Min similarity: \(minSimilarity), max similartiy: \(maxSimilarity)")
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
