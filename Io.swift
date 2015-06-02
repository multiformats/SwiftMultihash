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
    func readMultihash() -> Result<Multihash>
}

protocol Writer {
    func writeMultihash(mHash: Multihash) -> NSError?
}

func newReader() -> Reader {
    return MultihashReader()
}

struct MultihashReader {
    let inStream = NSInputStream()
}

/*
    Maybe it is better to make an extension to the NSStream that adds a
    readMultihash and writeMultihash rather than all this Golang stuff.
    We still need to provide the Reader and Writer protocols so the ipfs calls 
    can stay the same, but those can just call the extended NSStream.
    Perhaps we can even avoid extending NSStream by embedding an NSInputStream
    and NSOutputstream in the MultihashReader and MultihashWriter structs.
*/
//public func read(mhR: MultihashReader, buffer: [uint8]) -> Result<[uint8]> {
//    
//}

extension MultihashReader: Reader {
    func readMultihash() -> Result<Multihash> {
        return Result(value: Multihash([]))
    }
}

struct MultihashWriter {
    
}

extension MultihashWriter: Writer {
    func writeMultihash(mHash: Multihash) -> NSError? {
        return nil
    }
}