//
//  SwiftMultihash.swift
//  SwiftMultihash
//
//  Created by Teo on 18/05/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//

import Foundation

/// Errors
let ErrDomain = "MultiHashDomain"
let
    ErrUnknownCode      = NSError(domain: ErrDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown multihash code"]),
    ErrTooShort         = NSError(domain: ErrDomain, code: -2, userInfo: [NSLocalizedDescriptionKey : "Multihash too short. Must be > 3 bytes"]),
    ErrTooLong          = NSError(domain: ErrDomain, code: -3, userInfo: [NSLocalizedDescriptionKey : "Multihash too long. Must be < 129 bytes"]),
ErrLenNotSupported  = NSError(domain: ErrDomain, code: -4, userInfo: [NSLocalizedDescriptionKey : "Multihash does not yet support digests longer than 127 bytes"])

struct ErrInconsistentLen {
    let dm: DecodedMultihash
}

extension ErrInconsistentLen {
    func error() -> String {
        return "Multihash length inconsistent: \(dm)"
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

struct DecodedMultihash {
    let code    : Int
    let name    : String
    let length  : Int
    let digest  : [uint8]
}

typealias Multihash = [uint8]

//extension Multihash {
////    func hexString() -> String {
////        return
////    }
//}


/// Encode a hash digest along with the specified function code
/// Note: The length is derived from the length of the digest.
func encode(buf: [uint8], code: Int?) -> ([uint8]?, NSError?) {

    if validCode(code) == false {
        return (nil,ErrUnknownCode)
    }
    
    if buf.count > 129 {
        return (nil, ErrTooLong)
    }
    
    var pre = [0,0] as [uint8]
    
    pre[0] = uint8(code!)
    pre[1] = uint8(pre.count)
    pre.extend(buf)
    return (pre,nil)
}

func encodeName(buf: [uint8], name: String) -> ([uint8]?,NSError?) {
    return encode(buf, Names[name])
}

/// ValidCode checks whether a multihash code is valid.
func validCode(code: Int?) -> Bool {
    
    if let c = code {
        if appCode(c) == true {
            return true
        }
        
        if let ok = Codes[c] {
            return true
        }
    }
    return false
}

/// AppCode checks whether a multihash code is part of the App range.
func appCode(code: Int) -> Bool {
    return code >= 0 && code < 0x10
}