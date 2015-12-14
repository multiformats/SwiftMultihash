//
//  SwiftMultihash.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 18/05/15.
//  Licensed under MIT See LICENCE for details 
//

import Foundation
import SwiftHex
import SwiftBase58

enum MultihashError : ErrorType {
    case UnknownCode
    case HashTooShort
    case HashTooLong
    case LengthNotSupported
    case HexConversionFail
    case InconsistentLength(Int)
}

// English language error strings.
extension MultihashError {
    var description: String {
        get {
            switch self {
            case .UnknownCode:
                return "Unknown multihash code."
            case HashTooShort:
                return "Multihash too short. Must be > 3 bytes"
            case HashTooLong:
                return "Multihash too long. Must be < 129 bytes"
            case LengthNotSupported:
                return "Multihash does not yet support digests longer than 127 bytes"
            case HexConversionFail:
                return "Error occurred in hex conversion."
            case InconsistentLength(let len):
                return "Multihash length inconsistent. \(len)"
            }
        }
    }
}

let
SHA1        = 0x11,
SHA2_256    = 0x12,
SHA2_512    = 0x13,
SHA3        = 0x14,
BLAKE2B     = 0x40,
BLAKE2S     = 0x41

let Names: [String : Int] = [
    "sha1"      : SHA1,
    "sha2-256"  : SHA2_256,
    "sha2-512"  : SHA2_512,
    "sha3"      : SHA3,
    "blake2b"   : BLAKE2B,
    "blake2s"   : BLAKE2S
]

let Codes: [Int : String] = [
    SHA1        : "sha1",
    SHA2_256    : "sha2-256",
    SHA2_512    : "sha2-512",
    SHA3        : "sha3",
    BLAKE2B     : "blake2b",
    BLAKE2S     : "blake2s"
]

let DefaultLengths: [Int : Int] = [
    SHA1        : 20,
    SHA2_256    : 32,
    SHA2_512    : 64,
    SHA3        : 64,
    BLAKE2B     : 64,
    BLAKE2S     : 32
]

public struct DecodedMultihash {
    public let
        code    : Int,
        name    : String?,
        length  : Int,
        digest  : [UInt8]
}

public struct Multihash {
    public let value: [UInt8]
    
    public init(_ val: [UInt8]) {
        self.value = val
    }
}

extension Multihash : Equatable {
    public func hexString() -> String {
        return SwiftHex.encodeToString(value)
    }
    
    public func string() -> String {
        return self.hexString()
    }
}

public func ==(lhs: Multihash, rhs: Multihash) -> Bool {
    return lhs.value == rhs.value
}

public func fromHexString(theString: String) throws -> Multihash {
    
    let buf = try SwiftHex.decodeString(theString) 
    
    return try cast(buf)
}

public func b58String(mhash: Multihash) -> String {
    return SwiftBase58.encode(mhash.value)
}


public func fromB58String(str: String) throws -> Multihash {
    let decodedBytes = SwiftBase58.decode(str)
    return try cast(decodedBytes)
}

public func cast(buf: [UInt8]) throws -> Multihash {
    let dm = try decodeBuf(buf)

    if validCode(dm.code) == false {
        throw MultihashError.UnknownCode
    }

    return Multihash(buf)
}

public func decodeBuf(buf: [UInt8]) throws -> DecodedMultihash {
    
    if buf.count < 3 {
        throw MultihashError.HashTooShort
    }
    if buf.count > 129 {
        throw MultihashError.HashTooLong
    }

    let dm = DecodedMultihash(code: Int(buf[0]), name: Codes[Int(buf[0])], length: Int(buf[1]), digest: Array(buf[2..<buf.count]))
    
    if dm.digest.count != dm.length {
        throw MultihashError.InconsistentLength(dm.length)
    }

   return dm
}

/// Encode a hash digest along with the specified function code
/// Note: The length is derived from the length of the digest.
public func encodeBuf(buf: [UInt8], code: Int?) throws -> [UInt8] {
    if validCode(code) == false {
        throw MultihashError.UnknownCode
    }
    
    if buf.count > 129 {
        throw MultihashError.HashTooLong
    }
    
    var pre = [0,0] as [UInt8]
    
    pre[0] = UInt8(code!)
    pre[1] = UInt8(buf.count)
    pre.appendContentsOf(buf)

    return pre
}

public func encodeName(buf: [UInt8], name: String) throws -> [UInt8] {
    return try encodeBuf(buf, code: Names[name])
}

/// ValidCode checks whether a multihash code is valid.
public func validCode(code: Int?) -> Bool {
    
    if let c = code {
        if appCode(c) == true {
            return true
        }
        
        if let _ = Codes[c] {
            return true
        }
    }
    return false
}

/// AppCode checks whether a multihash code is part of the App range.
public func appCode(code: Int) -> Bool {
    return code >= 0 && code < 0x10
}