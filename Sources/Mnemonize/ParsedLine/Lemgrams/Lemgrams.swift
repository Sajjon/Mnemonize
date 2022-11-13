//
//  Lemgrams.swift
//  
//
//  Created by Alexander Cyon on 2019-10-23.
//

import Foundation

// MARK: Lemgrams
public struct Lemgrams: Sendable, Hashable, CustomStringConvertible {
    public typealias Element = Lemgram
    public let contents: [Lemgram]

    public init(single: Lemgram) {
        self.contents = [single]
    }

    public init(_ contents: [Element]) throws {
        if contents.isEmpty { throw Error.cannotBeEmpty }
        self.contents = contents
    }
}

public extension Lemgrams {

    /// Input is the third column in the line:
    /// `|land..nn.3|land..nn.2|land..nn.1|`
    /// containing 0 to many lemgrams, in the case of zero lemgrams the string is only an single pipe `|`.
    init(linePart: String) throws {
        let parts = linePart.parts(separatedBy: Self.delimiter)

        var lemgrams = [Lemgram]()
        for part in parts {
            let lemgram = try Lemgram(linePart: part)
            lemgrams.append(lemgram)
        }

        try self.init(lemgrams)
    }
}

public extension Lemgrams {
    static let delimiter: Character = "|"
}

public extension Lemgrams {
    enum Error: Int, Swift.Error, Equatable {
        case cannotBeEmpty
    }
}


// MARK: CustomStringConvertible
public extension Lemgrams {
    var description: String {
        String(describing: contents)
    }
}
