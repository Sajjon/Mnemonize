//
//  Word.swift
//  
//
//  Created by Alexander Cyon on 2019-10-23.
//

import Foundation

public struct WordForm:
    Sendable,
    WordFromString,
    CustomStringConvertible,
    Hashable,
    Codable,
    ExpressibleByStringLiteral
{

    public let lowercasedWord: String

    public init(linePart anyCase: String) throws {
        self.lowercasedWord = try Self.from(unvalidatedString: anyCase)
    }
}


// MARK: ExpressibleByStringLiteral
public extension WordForm {
    init(stringLiteral string: String) {
        do {
            try self.init(linePart: string)
        } catch {
            fatalError("Bad literal: \(error)")
        }
    }
}

// MARK: CustomStringConvertible
public extension WordForm {
    var description: String { lowercasedWord }
}
