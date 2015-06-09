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
    may use some paradigms that are not dogmatic Swift.

    A more Swifty future version would extend NSInputStream and NSOutputStream
    with multihashReader and multihashWriter methods.
*/

import Foundation
//import SwiftMultihash

public let
    ErrEOB      = NSError(domain: ErrDomain, code: -7, userInfo: [NSLocalizedDescriptionKey : "Error! End of buffer reached."]),
    ErrOpFail      = NSError(domain: ErrDomain, code: -7, userInfo: [NSLocalizedDescriptionKey : "Error! Operation failed."])

let defaultBufSize = 1024
// Reader is an NSInputStream wrapper that exposes a function 
// to read a whole multihash and return it.
public protocol Reader {
    func readMultihash() -> Result<Multihash>
}

// Writer is an NSOutputStream wrapper that exposes a function
// to write a whole multihash.
public protocol Writer {
    func writeMultihash(mHash: Multihash) -> NSError?
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
    public func read() -> Result<[uint8]> {
        
        var readBuf = [uint8](count: defaultBufSize, repeatedValue: 0)
        let r = inStream.read(&readBuf, maxLength: defaultBufSize)
        
        if r <= 0 {
            return parseReadError(r)
        }

        return Result(value: readBuf)
    }


    public func readMultihash() -> Result<Multihash> {

        // Read just the header first.
        var multihashHeader = [uint8](count: 2, repeatedValue: 0)
        let resultCode = inStream.read(&multihashHeader, maxLength: multihashHeader.count)
        if resultCode <= 0 {
            return parseReadError(resultCode)
        }
        
        let hashLength = Int(multihashHeader[1])
    
        if hashLength > 127 {
            // return varints not yet supported error
            return Result(error: ErrEOB)
        }
        
        // Read the rest
        var multiHash = [uint8](count: hashLength, repeatedValue: 0)
        if inStream.read(&multiHash, maxLength: hashLength) <= 0 {
            return Result(error: ErrEOB)
        }
        
        return cast(multihashHeader+multiHash)
    }
    
    func parseReadError<T>(errorCode: Int) -> Result<T> {
        switch true {
        case errorCode == 0:
            return Result(error: ErrEOB)
        case errorCode < 0:
            return Result(error: ErrOpFail)
        default:
            // No error error!
            return Result(error: ErrUnknownCode)
        }
    }
}

extension MultihashWriter: Writer {
    
    func write(buffer: [uint8]) -> NSError? {
        var buf = buffer
        let resultCode = outStream.write(&buf, maxLength: buf.count)
        if resultCode < 0 {
            return parseWriteError(resultCode)
        }
        
        return nil
    }

    public func writeMultihash(mHash: Multihash) -> NSError? {
        var hashBuf = mHash.value
        let resultCode = outStream.write(&hashBuf, maxLength: hashBuf.count)
        if resultCode < 0 {
            return parseWriteError(resultCode)
        }
        
        return nil
    }
    
    func parseWriteError(errorCode: Int) -> NSError? {
        switch true {
        case errorCode == 0:
            return ErrEOB
        case errorCode < 0:
            return ErrOpFail
        default:
            // No error error!
            return nil
        }
    }

}