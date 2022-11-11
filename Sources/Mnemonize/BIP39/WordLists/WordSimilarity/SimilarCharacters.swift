//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public struct SimilarCharacters: Sendable, Hashable {
    public let pairs: [(Character, Character)]
}
public extension SimilarCharacters {
    func contains(_ needle: (Character, Character)) -> Bool {
        pairs
            .contains(where: {
                ($0.0 == needle.0 && $0.1 == needle.1) ||
                ($0.0 == needle.1 && $0.1 == needle.0)
            })
    }
}

public extension SimilarCharacters {
    static let english = Self(pairs: [
        ("a", "e"),
        ("d", "t"),
    ])
}

public extension SimilarCharacters {
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.pairs.count == rhs.pairs.count else {
            return false
        }
        for index in 0..<lhs.pairs.count {
            let l = lhs.pairs[index]
            let r = rhs.pairs[index]
            guard (l.0 == r.0 && l.1 == r.1) || (l.0 == r.1 && l.1 == r.0) else {
                continue
            }
            return false
        }
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        for pair in pairs {
            hasher.combine(pair.0)
            hasher.combine(pair.1)
        }
    }
}
