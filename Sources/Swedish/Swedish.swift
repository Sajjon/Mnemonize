import Foundation
import ArgumentParser
import Mnemonize
import New

@main
public struct Swedish: ParsableCommand {

    @Argument(help: "The Swedish Part of Speech tagged corpus file.")
    var inputFile: String = "swedish_corpus_first_10k_lines.txt"
    
    
    @Option(
        name: .shortAndLong,
        help: "The number of lines from Swedish 'corpus' to read. Must be greater than or equal to 2048. If no value is provided, 100 000 lines will be used (arbitrarily set)"
    )
    var numberOfLinesToRead: Int = 100_000
    
    
    @Argument(help: "The output file with the BIP39 compatible word list.")
    var outputFile: String = "swedish_bip39.txt"
    
    public init() {}
}

public extension Swedish {
    mutating func run() throws {
        let pwd = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Developer/Mnemonize")
     
        let outputFilePath = pwd.appending(path: outputFile)
        guard FileManager.default.fileExists(atPath: outputFilePath.path()) else {
            fatalError("output file not found at: \(outputFilePath)")
        }
        let outputFileHandle = try FileHandle(forWritingTo: outputFilePath)

        let corpus = try Corpus(
            file: pwd.appending(path: inputFile)
        )
        
                            
        let mnemonizer = Mnemonizer(
            corpus: corpus,
            lineParser: .spraakbanken,
            bip39Validation: .swedishStrict,
            numberOfLinesToRead: numberOfLinesToRead,
            language: "Swedish",
            outputFile: outputFileHandle
        )
        
        let bip39WordList = try mnemonizer.mnemonize()
        print("🇸🇪  Found, word list of #\(bip39WordList.words.count) words:")
        bip39WordList.words.forEach {
            print($0)
        }
        print("🇸🇪  Done, word list of #\(bip39WordList.words.count) words ✅")
    }
}


public extension BIP39WordList.Validation {
    
    static let swedishStrict = Self(
        unambiguouslyIdentifiableInput: .strict,
        similarWordsDetectionInput: .swedishStrict,
        sorting: .strict
    )
}

public extension BIP39WordList.Validation.WordSimilarity.Input {

    static let swedishStrict = Self(
        threshold: Self.defaultThreshold,
        similarWordPairsInput: .swedishDefault
    )
}

public extension BIP39WordList.Validation.WordSimilarity.SimilarWordPairsInput {
    static let swedishDefault = Self(correlatedCharactersSet: .swedish)
}

public extension BIP39WordList.Validation.WordSimilarity.CorrelatedCharactersSet {
    static let swedish = Self(set: [
        .init("å", "ä", correlationFactor: 0.7),
        .init("ö", "o", correlationFactor: 0.6),
        .init("n", "t", correlationFactor: 2), // "åren" vs "året"
    ])
}
