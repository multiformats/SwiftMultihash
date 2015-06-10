//
//  Io.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 01/06/15.
//  Copyright (c) 2015 Matteo Sartori. All rights reserved.
//
/*
    This is the inital port of the golang io wrapper for Multihash.
    It is a direct translation of the go implementation and as such
    may use some paradigms that are not idiomatic Swift.

    A more Swifty future version would extend NSInputStream and NSOutputStream
    with multihashReader and multihashWriter methods.
*/

import Foundation

enum MultihashIOError : ErrorType {
    case EndOfBuffer
    case OperationFailure
}

// English language error descriptions
extension MultihashIOError {
    var description: String {
        get {
            switch self {
            case .EndOfBuffer:
                return "End of buffer reached."
            case .OperationFailure:
                return "Operation failure."
            }
        }
    }
}

let defaultBufSize = 1024

// Reader is an NSInputStream wrapper that exposes a function 
// to read a whole multihash and return it.
public protocol Reader {
    func readMultihash() throws -> Multihash
}

// Writer is an NSOutputStream wrapper that exposes a function
// to write a whole multihash.
public protocol Writer {
    func writeMultihash(mHash: Multihash) throws
}

public func newReader(reader: NSInputStream) -> Reader {
    return MultihashReader(inStream: reader)
}

public func newWriter(writer: NSOutputStream) -> Writer {
    return MultihashWriter(outStream: writer)
}

public struct MultihashReader {
    let inStream: NSInputStream
}

public struct MultihashWriter {
    let outStream: NSOutputStream
}

extension MultihashReader: Reader {
    
    public func read() throws -> [uint8] {
        
        var readBuf = [uint8](count: defaultBufSize, repeatedValue: 0)
        try inStream.readToBuffer(&readBuf, maxLength: defaultBufSize)

        return readBuf
    }

    public func readMultihash() throws -> Multihash {

        // Read just the header first.
        var multihashHeader = [uint8](count: 2, repeatedValue: 0)
        try inStream.readToBuffer(&multihashHeader, maxLength: multihashHeader.count)
        
        let hashLength = Int(multihashHeader[1])
    
        if hashLength > 127 {
            // return varints not yet supported error
            throw MultihashIOError.EndOfBuffer
        }
        
        // Read the rest
        var multiHash = [uint8](count: hashLength, repeatedValue: 0)
        try inStream.readToBuffer(&multiHash, maxLength: hashLength)
        
        return try cast(multihashHeader+multiHash)
    }
}

extension NSInputStream {
    func readToBuffer(buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) throws -> Int {
        let result = read(buffer, maxLength: len)
        switch true {
        case result == 0:
            throw MultihashIOError.EndOfBuffer
        case result < 0:
            throw MultihashIOError.OperationFailure
        default:
            return result
        }
    }
}

extension MultihashWriter: Writer {
    
    func write(buffer: [uint8]) throws {
        var buf = buffer
        try outStream.writeBuffer(&buf, maxLength: buf.count)
    }

    public func writeMultihash(mHash: Multihash) throws {
        var hashBuf = mHash.value
        try outStream.writeBuffer(&hashBuf, maxLength: hashBuf.count)
    }
}

extension NSOutputStream {
    func writeBuffer(buffer: UnsafePointer<UInt8>, maxLength len: Int) throws -> Int {
        let result = write(buffer, maxLength: len)
        switch true {
        case result == 0:
            throw MultihashIOError.EndOfBuffer
        case result < 0:
            throw MultihashIOError.OperationFailure
        default:
            return result
        }
    }
}
