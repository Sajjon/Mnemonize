import XCTest
@testable import Mnemonize

public struct Vector {
   
    public let word0: String
    public let word1: String
    public let shouldBeConsideredSimilar: Bool
    
    public init(word0: String, word1: String, shouldBeConsideredSimilar: Bool) {
        self.word0 = word0
        self.word1 = word1
        self.shouldBeConsideredSimilar = shouldBeConsideredSimilar
    }
}
public extension Vector {
    static func similar(_ word0: String, and word1: String) -> Self {
        .init(word0: word0, word1: word1, shouldBeConsideredSimilar: true)
    }
    static func unsimilar(_ word0: String, and word1: String) -> Self {
        .init(word0: word0, word1: word1, shouldBeConsideredSimilar: false)
    }
}


final class MnemonizeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_few_vectors() throws {
        [
            .similar("build", and: "built"),
            .similar("woman", and: "women"),
            .similar("quick", and: "quickly"),
            
            .unsimilar("able", and: "cable"),
            .unsimilar("abandon", and: "admit")
        ].forEach(doTest)
    }
    
    func test_bip39() throws {
        
        XCTAssertThrowsError(
            try BIP39WordList(
                words: .init(uncheckedUniqueElements: ["almostthesame", "almostthesama"]),
                language: "should throw",
                validation: .strict
            )
        )
        
        XCTAssertNoThrow(
            try BIP39WordList(
                words: .init(uncheckedUniqueElements: WordLists.english),
                language: "English",
                validation: .strict
            )
        )
    }

    
}

private extension MnemonizeTests {
    func doTest(_ vector: Vector) {
        let word0 = vector.word0
        let word1 = vector.word1
        
        let maxSimilarityThreshold: Double = BIP39WordList.defaultThreshold
        
        let similar = BIP39WordList.similar(
            word0: word0,
            word1: word1
        )
        
        switch (vector.shouldBeConsideredSimilar, similar.similarity > maxSimilarityThreshold) {
        case (true, true):
            print("✅ '\(word0)' and '\(word1)' are \(similar.similarity*100)% similar, exceeding expectation of \(maxSimilarityThreshold*100)%.")
        case (true, false):
            XCTFail("❌ Expected similarity to exceed threshold, but it did not: \(similar)")
        case (false, false):
            print("✅ '\(word0)' and '\(word1)' are \(similar.similarity*100)% similar, which is lower \(maxSimilarityThreshold*100)% as expected.")
        case (false, true):
            XCTFail("❌ Unexpected similarity \(similar)")
        }
    }
}
