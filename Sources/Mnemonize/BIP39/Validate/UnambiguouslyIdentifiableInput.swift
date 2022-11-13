//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation
import Collections

public extension BIP39WordList.Validation {
    struct UnambiguouslyIdentifiableInput {
        public let charCount: Int
        
        /// Strict according to [`BIP39`][bip]:
        ///
        /// "the wordlist is created in such a way that it's enough to type the **first four** letters to unambiguously identify the word"
        ///
        /// [bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
        public static let strict = Self(charCount: 4)
        
    }
}

public extension BIP39WordList.Validation {
    static func unambiguouslyIdentifiableByFirst(
        n input: UnambiguouslyIdentifiableInput,
        _ words: OrderedSet<String>
    ) -> ConflictingWords? {
        unambiguouslyIdentifiableByFirst(input.charCount, lettersIn: words)
    }
    
    static func unambiguouslyIdentifiableByFirst(
        _ letterCount: Int,
        lettersIn words: OrderedSet<String>
    ) -> ConflictingWords? {
        struct Val: Hashable {
            let prefix: String.SubSequence
            let word: String
        }
        var set = Set<Val>()
        for word in words {
            let prefix = word.prefix(letterCount)
            if let existingVal = set.first(where: { $0.prefix == prefix }) {
                return .init(word0: existingVal.word, word1: word)
            } else {
                set.insert(.init(prefix: prefix, word: word))
            }
        }
        return nil
    }
}
