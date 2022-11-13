//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-11-11.
//

import Foundation
import Mnemonize

public extension LineParser {
    static var spraakbanken: Self = {
        Self(parse: { readLine in
            try? ParsedLine.fromReadLine(readLine)
        })
    }()
}
