//
//  Io.swift
//  SwiftMultihash
//
//  Created by Teo on 01/06/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//

import Foundation
import SwiftMultihash

protocol Reader {
    func readMultihash() -> (Multihash?, NSError?)
}

protocol Writer {
    func writeMultihash(mHash: Multihash) -> NSError?
}

func newReader() -> Reader {
    return MultihashReader()
}

struct MultihashReader {
    
}

//public func read(mhR: MultihashReader, buffer: [uint8]) -> (type that is either a thing or an error)
extension MultihashReader: Reader {
    func readMultihash() -> (Multihash?, NSError?) {
        return (nil,nil)
    }
}

struct MultihashWriter {
    
}

extension MultihashWriter: Writer {
    func writeMultihash(mHash: Multihash) -> NSError? {
        return nil
    }
}