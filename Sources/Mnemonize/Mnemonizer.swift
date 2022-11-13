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
        case anotherFormOfSameWordExistsWithSamePOSTag
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

            func lineConflicts(
                reason similarityReason: Choose.Reason,
                checkForConflict: (OrderedSet<ParsedLine>, ParsedLine) -> ConflictingWords?
            ) -> Bool {
                guard
                    let conflict = checkForConflict(.init(parsedLines + [parsedLine]), parsedLine),
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
            
            func wordConflicts(
                reason similarityReason: Choose.Reason,
                checkForConflict: (OrderedSet<String>, ParsedLine) -> ConflictingWords?
            ) -> Bool {
                lineConflicts(
                    reason: similarityReason,
                    checkForConflict: { linesIncludingNew, new in
                        checkForConflict(.init(linesIncludingNew.map { $0.wordForm.lowercasedWord }), new)
                    })
            }
            
            if
                lineConflicts(reason: .anotherFormOfSameWordExistsWithSamePOSTag, checkForConflict: { _, newLine in
                    // snart    AB.POS    |snart..ab.1|snar..av.1|
                    parsedLines.compactMap({ existing -> ConflictingWords? in
                        
                        guard
                            existing.partOfSpeechTag == newLine.partOfSpeechTag,
                            existing.wordForm.lowercasedWord != newLine.wordForm.lowercasedWord,
                            let match = newLine.lemgrams.contents.first(where: {
                                $0.baseForm.word == existing.wordForm.lowercasedWord
                        }) else {
                            return nil
                        }
                        let conflictingWords = ConflictingWords(word0: match.baseForm.word, word1: newLine.wordForm.lowercasedWord)
                        return conflictingWords
                        
                    }).first
                })
            {
                continue
            }
            
            if
                let input = bip39Validation.unambiguouslyIdentifiableInput,
                wordConflicts(reason: .ambigiousByFirstNLetters, checkForConflict: { wordsIncludingNew, newLine in
                    BIP39WordList.Validation.unambiguouslyIdentifiableByFirst(n: input, wordsIncludingNew)
                })
            {
                continue
            }
            
            if
                let input = bip39Validation.similarWordsDetectionInput,
                wordConflicts(reason: .similar, checkForConflict: { wordsIncludingNew, newLine in
                    BIP39WordList.Validation.similarWords(wordsIncludingNew, input: input)?.conflictingWords
                })
            {
                continue
            }
            
            parsedLines.append(parsedLine)
            
        }
        
        if
            case let sameLemma = choices.filter({ $0.key.reason == .anotherFormOfSameWordExistsWithSamePOSTag }),
            !sameLemma.isEmpty
        {
            print(
                "\n\n🔮 CHOOSE BETWEEN WORDS OF SAME LEMMA AND POS TAG:\n" +
                sameLemma
                    .map {
                        [
                            "Alternatives to '\($0.key.reference.wordForm.lowercasedWord)': ",
                            $0.value.map { "'\($0.wordForm.lowercasedWord)'" }.joined(separator: ", ")
                        ].joined()
                    }.joined(separator: "\n")
            )
        } else {
            print("✨ No words of same lemma and POSTag found.")
        }
        
        if
            case let amb = choices
                .filter({ $0.key.reason == .ambigiousByFirstNLetters }),
            !amb.isEmpty
        {
            print(
                "\n\n🔮 CHOOSE BETWEEN AMBIGIOUS WORDS:\n" +
                amb
                    .map {
                        [
                            "Alternatives to '\($0.key.reference.wordForm.lowercasedWord)': ",
                            $0.value.map { "'\($0.wordForm.lowercasedWord)'" }.joined(separator: ", ")
                        ].joined()
                    }.joined(separator: "\n")
            )
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
                            "Alternatives to '\($0.key.reference.wordForm.lowercasedWord)': ",
                            $0.value.map { "'\($0.wordForm.lowercasedWord)'" }.joined(separator: ", ")
                        ].joined()
                    }.joined(separator: "\n")
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

