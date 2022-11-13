//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation
import Collections

extension OrderedSet: @unchecked Sendable where Element: Sendable {}

public extension BIP39WordList.Validation.WordSimilarity {
    struct CorrelatedCharactersSet: Sendable, Hashable {
        
        public let set: OrderedSet<CorrelatedCharacters>
        
        public init(set: OrderedSet<CorrelatedCharacters>) {
            self.set = set
        }
    }
}

public extension BIP39WordList.Validation.WordSimilarity.CorrelatedCharactersSet {
    
    struct CorrelatedCharacters: Sendable, Hashable {
       
        public let char0: Character
        public let char1: Character
        public let correlationFactor: Double
       
        public static let defaultCorrelationFactor: Double = 0.4
       
        public init(
            char0: Character,
            char1: Character,
            correlationFactor: Double = Self.defaultCorrelationFactor
        ) {
            self.char0 = char0
            self.char1 = char1
            self.correlationFactor = correlationFactor
        }
        public init(_ char0: Character, _ char1: Character, correlationFactor: Double = Self.defaultCorrelationFactor) {
            self.init(
                char0: char0,
                char1: char1,
                correlationFactor: correlationFactor
            )
        }
    }
    
    func contains(_ needle: (Character, Character)) -> CorrelatedCharacters? {
        self.set.first(where: {
            $0.char0 == needle.0 && $0.char1 == needle.1 ||
            $0.char0 == needle.1 && $0.char1 == needle.0
        })
    }
}

public extension BIP39WordList.Validation.WordSimilarity.CorrelatedCharactersSet {
    static let english = Self(set: [
        .init("a", "e"),
        .init("d", "t"),
    ])
}

