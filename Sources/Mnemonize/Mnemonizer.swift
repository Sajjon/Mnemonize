import Foundation
import Collections

/// A Part of Speech (PoS) tagged corpus file sorted by frequency,
/// with the most frequent word at line 0.
public struct Corpus {
    public let fileHandle: FileHandle
    public init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }
}

public struct Mnemonizer {
    
    public let corpus: Corpus
    public let numberOfLinesToRead: Int
    public let language: String
    public let outputFile: FileHandle
    
    public init(
        corpus: Corpus,
        numberOfLinesToRead: Int,
        language: String,
        outputFile: FileHandle
    ) {
        self.corpus = corpus
        self.numberOfLinesToRead = numberOfLinesToRead
        self.language = language
        self.outputFile = outputFile
    }
}


public extension Mnemonizer {
    
    @discardableResult
    func mnemonize() throws -> BIP39WordList {
        
    }
}
