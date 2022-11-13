//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-12.
//

import Foundation

public struct LineSelector {
    public var selects: Selects
    public init(selects: @escaping Selects) {
        self.selects = selects
    }
}
public extension LineSelector {
    typealias Selects = @Sendable (ParsedLine) -> Bool
}
public extension LineSelector {
    static let liveValue: Self = {
        Self.init(selects: {
            guard $0.wordForm.lowercasedWord.count >= 3 else {
                return false
            }
            switch $0.partOfSpeechTag {
            case .noun, .adjective, .verb, .cardinalNumber, .possessive:
                break
            case .adverb, .determiner, .foreignWord, .conjunction, .infinitiveMarker, .interjection, .relativeInterogativeAdverb, .relativeInterogativeDeterminer,  .relativeInterogativePronoun, .relativeInterogativePossesivePronoun, .participle, .particle, .properNoun, .pronoun, .preposition, .ordinalNumber,  .subjunction:
                return false
            }
            
            return true
        })
    }()
}
