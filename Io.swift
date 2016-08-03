//
//  Io.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 01/06/15.
//  Licensed under MIT See LICENCE for details
//
/*
    This is the inital port of the golang io wrapper for Multihash.
    It is a direct translation of the go implementation and as such
    may use some paradigms that are not idiomatic Swift.

    A more Swifty future version would extend NSInputStream and NSOutputStream
    with multihashReader and multihashWriter methods.
*/

import Foundation

enum MultihashIOError : Error {
    case endOfBuffer
    case operationFailure
}

// English language error descriptions
extension MultihashIOError {
    var description: String {
        get {
            switch self {
            case .endOfBuffer:
                return "End of buffer reached."
            case .operationFailure:
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
    func writeMultihash(_ mHash: Multihash) throws
}

public func newReader(_ reader: InputStream) -> Reader {
    return MultihashReader(inStream: reader)
}

public func newWriter(_ writer: NSOutputStream) -> Writer {
    return MultihashWriter(outStream: writer)
}

public struct MultihashReader {
    let inStream: InputStream
}

public struct MultihashWriter {
    let outStream: NSOutputStream
}

extension MultihashReader: Reader {
    
    public func read() throws -> [UInt8] {
        
        var readBuf = [UInt8](repeating: 0, count: defaultBufSize)
        try _ = inStream.readToBuffer(&readBuf, maxLength: defaultBufSize)

        return readBuf
    }

    public func readMultihash() throws -> Multihash {

        // Read just the header first.
        var multihashHeader = [UInt8](repeating: 0, count: 2)
        try _ = inStream.readToBuffer(&multihashHeader, maxLength: multihashHeader.count)
        
        let hashLength = Int(multihashHeader[1])
    
        if hashLength > 127 {
            // return varints not yet supported error
            throw MultihashIOError.endOfBuffer
        }
        
        // Read the rest
        var multiHash = [UInt8](repeating: 0, count: hashLength)
        try _ = inStream.readToBuffer(&multiHash, maxLength: hashLength)
        
        return try cast(multihashHeader+multiHash)
    }
}

extension InputStream {
    func readToBuffer(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) throws -> Int {
        let result = read(buffer, maxLength: len)
        switch true {
        case result == 0:
            throw MultihashIOError.endOfBuffer
        case result < 0:
            throw MultihashIOError.operationFailure
        default:
            return result
        }
    }
}

extension MultihashWriter: Writer {
    
    func write(_ buffer: [UInt8]) throws {
        var buf = buffer
        try _ = outStream.writeBuffer(&buf, maxLength: buf.count)
    }

    public func writeMultihash(_ mHash: Multihash) throws {
        var hashBuf = mHash.value
        try _ = outStream.writeBuffer(&hashBuf, maxLength: hashBuf.count)
    }
}

extension NSOutputStream {
    func writeBuffer(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) throws -> Int {
        let result = write(buffer, maxLength: len)
        switch true {
        case result == 0:
            throw MultihashIOError.endOfBuffer
        case result < 0:
            throw MultihashIOError.operationFailure
        default:
            return result
        }
    }
}
