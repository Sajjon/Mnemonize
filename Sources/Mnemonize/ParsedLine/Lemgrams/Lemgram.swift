//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2019-12-08.
//

import Foundation

public struct Lemgram: Sendable, CustomStringConvertible, Hashable {
    private let b: BaseForm
    private let p: PartOfSpeech
    private let i: Int

    public init(baseForm: BaseForm, partOfSpeech: PartOfSpeech, index: Int = 0) {
        self.b = baseForm
        self.p = partOfSpeech
        self.i = index
    }

    /// Expects a `{word}..{pos}.{index}` format, i.e. any `|` should already have been removed.
    public init(linePart string: String) throws {
        let components = string.components(separatedBy: "..")

        guard components.count == 2 else {
            throw WordError.unexpectedNumberOfComponents(got: components.count, butExpected: 2)
        }

        let word = components[0]
        let posAndIndexComponents = components[1].components(separatedBy: ".")

        guard posAndIndexComponents.count == 2 else {
            throw WordError.unexpectedNumberOfComponents(got: posAndIndexComponents.count, butExpected: 2)
        }

        guard let index = Int(posAndIndexComponents[1]) else {
            throw WordError.stringNotAnInteger(posAndIndexComponents[1])
        }

        self.init(
            baseForm: try BaseForm(linePart: word),
            partOfSpeech: try PartOfSpeech(linePart: posAndIndexComponents[0]),
            index: index
        )
    }
}

public extension Lemgram {

    var baseForm: BaseForm { b }
    var partOfSpeech: PartOfSpeech { p }
    var index: Int { i }
}

// MARK: Equatable
public extension Lemgram {
    static func == (lhs: Self, rhs: Self) -> Bool {
        // omit `index`
        lhs.baseForm == rhs.baseForm && lhs.partOfSpeech == rhs.partOfSpeech
    }
}

// MARK: Hashable
public extension Lemgram {
    func hash(into hasher: inout Hasher) {
        // omit `index`
        hasher.combine(baseForm)
        hasher.combine(partOfSpeech)
    }
}

public extension Lemgram {
    struct BaseForm: WordFromString, Sendable, Hashable {
        public let w: String

        public init(linePart anyCase: String) throws {
            self.w = try Self.from(unvalidatedString: anyCase)
        }

        public init(wordForm: WordForm) {
            self.w = wordForm.lowercasedWord
        }
    }
}

public extension Lemgram {

    init(wordForm: WordForm, partOfSpeech: PartOfSpeech, index: Int = 0) {
        self.init(
            baseForm: BaseForm(wordForm: wordForm),
            partOfSpeech: partOfSpeech,
            index: index
        )
    }
}

public extension Lemgram.BaseForm {
    var word: String { w }
}

public extension Lemgram {
    var description: String {
        """
        \(baseForm.word) (\(partOfSpeech))
        """
    }
}
