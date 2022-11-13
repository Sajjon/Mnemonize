//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation
import Collections

public extension BIP39WordList {
    struct Validation {
        public let unambiguouslyIdentifiableInput: UnambiguouslyIdentifiableInput?
        public let similarWordsDetectionInput: WordSimilarity.Input?
        public let sorting: SortingInput?
        
        public init(
            unambiguouslyIdentifiableInput: UnambiguouslyIdentifiableInput?,
            similarWordsDetectionInput: WordSimilarity.Input?,
            sorting: SortingInput?
        ) {
            self.unambiguouslyIdentifiableInput = unambiguouslyIdentifiableInput
            self.similarWordsDetectionInput = similarWordsDetectionInput
            self.sorting = sorting
        }
    }
}

public extension BIP39WordList.Validation {
    enum Error: Swift.Error, Equatable {
        case expectedExactly2048Words(butGot: Int)
        case wordsAreNotLexicongraphicallySorted
        case wordsAreNotUnambigiouslyIdentifiedByFirstFourLetters(ambigiousWord0: String, ambigiousWord1: String)
        case similarWordsFound(WordSimilarity.Report)
    }
}

public extension BIP39WordList.Validation {
    
    func validate(_ words: OrderedSet<String>) throws {
        #if DEBUG
        #else
        guard words.count == 2048 else {
            throw Error.expectedExactly2048Words(butGot: words.count)
        }
        #endif // DEBUG
        
        if let input = unambiguouslyIdentifiableInput,
         let amb = Self.unambiguouslyIdentifiableByFirst(n: input, words)
        {
            throw Error.wordsAreNotUnambigiouslyIdentifiedByFirstFourLetters(ambigiousWord0: amb.word0, ambigiousWord1: amb.word1)
        }
        
        if let input = similarWordsDetectionInput,
           let similarWords = Self.similarWords(words, input: input)
        {
            throw Error.similarWordsFound(similarWords)
        }
        
        if let input = sorting,
           Self.areSorted(words: words, input: input)
        {
            throw Error.wordsAreNotLexicongraphicallySorted
        }
    }
}

public extension BIP39WordList.Validation {
    
    static let englishStrict = Self(
        unambiguouslyIdentifiableInput: .strict,
        similarWordsDetectionInput: .englishStrict,
        sorting: .strict
    )
}


public extension BIP39WordList.Validation {
    
    static func similarWords(
        _ words: OrderedSet<String>,
        input: WordSimilarity.Input
    ) -> WordSimilarity.Report? {
        guard words.count >= 2 else { return nil }
        var maxSimilarity = WordSimilarity.SimilarWords(
            word0: "_",
            word1: "_",
            similarity: .leastNonzeroMagnitude
        )
        var minSimilarity = WordSimilarity.SimilarWords(
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
                    return .init(
                        similarWords: similarity,
                        input: input
                    )
                }
            }
        }
//        let averageSimilarity = sum / Double(wordsChecked)
        return nil
    }
    
    
    static func similar(
        word0: String,
        word1: String
    ) -> WordSimilarity.SimilarWords {
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
