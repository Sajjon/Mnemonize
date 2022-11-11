//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

public struct SimilarWordsReport: Sendable, Hashable {
    public var similarWords: SimilarWords
    public let input: SimilarWordsInput
}
