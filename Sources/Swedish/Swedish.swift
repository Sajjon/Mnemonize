import Foundation
import ArgumentParser
import Mnemonize
import New

@main
public struct Swedish: ParsableCommand {

    @Argument(help: "The Swedish Part of Speech tagged corpus file.")
    var inputFile: String = "swedish_corpus_first_1k_lines.txt"
    
    
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
        print(bip39WordList)
    }
}


public extension BIP39WordList.Validation {
    
    static let swedishStrict = Self(
        unambiguouslyIdentifiableInput: .strict,
        similarWordsDetectionInput: .englishStrict,
        sorting: .strict
    )
}

public extension BIP39WordList.Validation.WordSimilarity.Input {
    
    
    /// Strict according to [`BIP39`][bip], which means that similar words are avoided:
    ///
    /// "word pairs like "build" and "built", "woman" and "women", or "quick" and "quickly"
    /// not only make remembering the sentence difficult but are also more error
    /// prone and more difficult to guess"
    ///
    /// [bip]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
    static let englishStrict = Self(
        threshold: Self.defaultThreshold,
        similarWordPairsInput: .englishDefault
    )
}
