//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public struct LineParser: Sendable {
    public var parse: ParseLine
    public init(parse: @escaping ParseLine) {
        self.parse = parse
    }
}

public extension LineParser {
    typealias ParseLine = @Sendable (ReadLine) throws -> ParsedLine?
}
