import Foundation
import Collections

public struct Mnemonizer {
    
    public let corpus: Corpus
    public let lineReader: LineReader
    public let lineParser: LineParser
    public let lineSelector: LineSelector
    public let bip39Validation: BIP39WordList.Validation
    public let numberOfLinesToRead: Int
    public let language: String
    public let outputFile: FileHandle
    
    public init(
        corpus: Corpus,
        lineReader: LineReader = .liveValue,
        lineParser: LineParser,
        lineSelector: LineSelector = .liveValue,
        bip39Validation: BIP39WordList.Validation = .englishStrict,
        numberOfLinesToRead: Int,
        language: String,
        outputFile: FileHandle
    ) {
        self.corpus = corpus
        self.lineReader = lineReader
        self.lineParser = lineParser
        self.lineSelector = lineSelector
        self.bip39Validation = bip39Validation
        self.numberOfLinesToRead = numberOfLinesToRead
        self.language = language
        self.outputFile = outputFile
    }
}


public struct Choose: Sendable, Hashable {
    public let reason: Reason
    public let reference: ParsedLine
    
    public enum Reason: String, Sendable, Hashable {
        case similar
        case ambigiousByFirstNLetters
    }
}

public extension Mnemonizer {
    
    @discardableResult
    func mnemonize() throws -> BIP39WordList {
        try corpus.open()
        var lineNumber = 0
        var parsedLines: [ParsedLine] = []
        var choices: [Choose: [ParsedLine]] = [:]
        
        while let rawLine = try corpus.nextLine() {
            defer { lineNumber += 1 }
            guard lineNumber <= numberOfLinesToRead else {
                break
            }
            let readLine = try lineReader.read(rawLine, lineNumber)
            guard
                let parsedLine = try lineParser.parse(readLine),
                lineSelector.selects(parsedLine)
            else {
                continue
            }

            let wordsSoFar = OrderedSet<String>((parsedLines + [parsedLine]).map { $0.wordForm.lowercasedWord })
            
            func wordConflicts(
                reason similarityReason: Choose.Reason,
                checkForConflict: (OrderedSet<String>) -> ConflictingWords?
            ) -> Bool {
                guard
                    let conflict = checkForConflict(wordsSoFar),
                    let reference = parsedLines.first(where: {
                        let needle = conflict.word0 == parsedLine.wordForm.lowercasedWord ? conflict.word1 : conflict.word0
                        return $0.wordForm.lowercasedWord == needle
                    }) else
                { return false }
              
                parsedLines.removeAll(where: { $0 == reference })
                let key = Choose(reason: similarityReason, reference: reference)
                if var existing = choices[key] {
                    existing.append(parsedLine)
                    choices[key] = existing
                } else {
                    choices[key] = [parsedLine]
                }
                return true
            }
            
            if
                let input = bip39Validation.unambiguouslyIdentifiableInput,
                wordConflicts(reason: .ambigiousByFirstNLetters, checkForConflict: {
                    BIP39WordList.Validation.unambiguouslyIdentifiableByFirst(n: input, $0)
                })
            {
                continue
            }
            
            if
                let input = bip39Validation.similarWordsDetectionInput,
                wordConflicts(reason: .similar, checkForConflict: {
                    BIP39WordList.Validation.similarWords($0, input: input)?.conflictingWords
                })
            {
                continue
            }
            
            parsedLines.append(parsedLine)
            
        }
        
        if
            case let amb = choices
                .filter({ $0.key.reason == .ambigiousByFirstNLetters }),
            !amb.isEmpty
        {
//            print(
//                "\n\n🔮 CHOOSE BETWEEN AMBIGIOUS WORDS:\n" +
//                amb
//                    .map {
//                        [
//                            "Ref: '\($0.key.reference.wordForm.lowercasedWord)' - alternatives",
//                            $0.value.map { $0.wordForm.lowercasedWord }.joined(separator: "\n\t")
//                        ].joined(separator: "\n")
//                    }.joined(separator: "\n\n")
//            )
        } else {
            print("✨ No ambigious words found.")
        }
        
        if
            case let sim = choices.filter({ $0.key.reason == .similar }),
            !sim.isEmpty
        {
            print(
                "\n\n🔮 CHOOSE BETWEEN SIMILAR WORDS:\n" +
                sim
                    .map {
                        [
                            "Ref: '\($0.key.reference.wordForm.lowercasedWord)' - alternatives",
                            $0.value.map { $0.wordForm.lowercasedWord }.joined(separator: "\n\t")
                        ].joined(separator: "\n")
                    }.joined(separator: "\n\n")
            )
        } else {
            print("✨ No similar words found.")
        }
        
        let unsorted = Set(parsedLines.map { $0.wordForm.lowercasedWord })
        let sorted = OrderedSet(unsorted.sorted())
        
//        print(sorted)
        
        
        return try BIP39WordList(
            words: sorted,
            language: language,
            validation: bip39Validation
        )
    }
}

