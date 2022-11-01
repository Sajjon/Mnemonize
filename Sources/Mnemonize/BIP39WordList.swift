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
        
        if
            validation.contains(.smartSectionOfWords),
            !Self.unambiguouslyIdentifiableByFirstFourLetters(words)
        {
            throw Error.wordsAreNotLexicongraphicallySorted
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
    }
}

public extension BIP39WordList {
    
    static func unambiguouslyIdentifiableByFirstFourLetters(
        _ words: OrderedSet<String>
    ) -> Bool {
        
    }
}
