//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation
import Collections

public extension BIP39WordList.Validation {
  
    struct SortingInput {
        public let sort: (OrderedSet<String>) -> [String]

        public init(sort: @escaping (OrderedSet<String>) -> [String]) {
            self.sort = sort
        }
    }
}

public extension BIP39WordList.Validation.SortingInput {
    
    static let lexicongraphically = Self(sort: { $0.sorted() })
    
    /// Strict according to [`BIP39`][bip]:
    ///
    /// "the wordlist is sorted which allows for more efficient lookup of the code words"
    ///
    /// [bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    static let strict: Self = .lexicongraphically
}

public extension BIP39WordList.Validation {
    
    static func areSorted(
        words: OrderedSet<String>,
        input: SortingInput
    ) -> Bool {
        input.sort(words) != words.elements
    }
 
}
