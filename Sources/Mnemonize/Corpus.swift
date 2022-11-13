//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation

/// A Part of Speech (PoS) tagged corpus file sorted by frequency,
/// with the most frequent word at line 0.
public struct Corpus: Sendable, Hashable {
   
    public let filePath: String
   
    public init(
        file: URL
    ) throws {
        let path = file.path()
        guard
            FileManager.default.fileExists(atPath: path)
        else {
            throw Error.noFileFoundAt(path)
        }
        _ = try FileHandle(forReadingFrom: file)
       
        self.filePath = path
    }
}

public extension Corpus {
    enum Error: Swift.Error, Sendable, Hashable {
        case noFileFoundAt(String)
    }
}

public extension Corpus {
    
    func open() throws {
        try FileHolder.shared.open(filePath: filePath)
    }
    
    func close() throws {
        try FileHolder.shared.close()
    }
    
    func nextLine() throws -> String? {
        try FileHolder.shared.nextLine()
    }
}

// MARK: FileHolder
internal extension Corpus {
 
    final class FileHolder {
        fileprivate var file: UnsafeMutablePointer<FILE>?
    }
    
}

internal extension Corpus.FileHolder {
    static let shared = Corpus.FileHolder()
    
    struct FileAlreadyOpen: Swift.Error {}
    struct FailedToOpenFile: Swift.Error {}
    struct FailedToCloseFile: Swift.Error {}
    struct NoFileOpened: Swift.Error {}
   
}

internal extension Corpus.FileHolder {
    
    func open(filePath: String) throws {
       
        guard file == nil else {
            throw FileAlreadyOpen()
        }
        
        guard let file = freopen(filePath, "r", stdin) else {
            throw FailedToOpenFile()
        }
        
        self.file = file
    }
    
    func close() throws {
        guard fclose(file) == 0 else {
            throw FailedToCloseFile()
        }
        file = nil
    }
    
    func nextLine() throws -> String? {
        guard file != nil else {
            throw NoFileOpened()
        }
        return readLine()
    }
}
