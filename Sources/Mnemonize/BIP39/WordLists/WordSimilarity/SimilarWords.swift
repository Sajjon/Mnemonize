//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation


public struct SimilarWords: Sendable, Hashable, Comparable, CustomStringConvertible {
    public var word0: String
    public var word1: String
    public var similarity: Double
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.similarity < rhs.similarity
    }
}

public extension SimilarWords {
    var description: String {
        """
        "\(word0)" vs "\(word1)" @ \(similarity * 100)%
        """
    }
}
