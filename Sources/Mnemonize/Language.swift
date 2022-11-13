//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2019-12-08.
//

import Foundation

public protocol Language {
    static var name: String { get }
    static var allowedCharacter: String { get }
}
public extension Language {
    static var name: String { "\(Self.self)" }
    var name: String { Self.name }
    var allowedCharacter: String { Self.allowedCharacter }
}

public extension Language {
    static var allowedCharacterSet: CharacterSet { .init(charactersIn: allowedCharacter) }
    var allowedCharacterSet: CharacterSet { Self.allowedCharacterSet }
}

public struct SwedishLanguage: Language {
    public init() {}
    public static let allowedCharacter = "abcdefghijklmnopqrstuvwxyzåäö"
}
