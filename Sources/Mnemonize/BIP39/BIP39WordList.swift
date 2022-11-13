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
        try validation.validate(words)
       
        self.words = words
        self.language = language
    }
}
