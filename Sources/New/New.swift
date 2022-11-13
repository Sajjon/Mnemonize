import Foundation
import ArgumentParser
import Mnemonize

@main
public struct New: ParsableCommand {

    @Argument(help: "The Part of Speech tagged corpus file.")
    var inputFile: String
    
    
    @Option(
        name: .shortAndLong,
        help: "The number of lines from 'corpus' to read. Must be greater than or equal to 2048. If no value is provided, 100 000 lines will be used (arbitrarily set)"
    )
    var numberOfLinesToRead: Int = 100_000
    
    @Argument(help: "The Language of the newly created BIP39 word list.")
    var language: String
    
    
    @Argument(help: "The output file with the BIP39 compatible word list.")
    var outputFile: String
    
    public init() {}
}

public extension New {
    mutating func run() throws {
        let pwd = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Developer/Mnemonize")
     
        
        guard
            let outputFileHandle = FileHandle(forWritingAtPath: outputFile)
        else {
            throw Error.failedToOpenOutputFile(atPath: outputFile)
        }
        
   
        let corpus = try Corpus(file: pwd.appending(path: inputFile))
                            
        let mnemonizer = Mnemonizer(
            corpus: corpus,
            lineParser: .init(parse: { _ in fatalError() }),
            numberOfLinesToRead: numberOfLinesToRead,
            language: language,
            outputFile: outputFileHandle
        )
        
        let bip39WordList = try mnemonizer.mnemonize()
        print(bip39WordList)
    }
}
                            

public extension New {
    enum Error: Swift.Error {
        case failedToOpenInputFile(atPath: String)
        case failedToOpenOutputFile(atPath: String)
    }
}
