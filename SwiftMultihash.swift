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
public let
ErrUnknownCode      = NSError(domain: ErrDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown multihash code"]),
ErrTooShort         = NSError(domain: ErrDomain, code: -2, userInfo: [NSLocalizedDescriptionKey : "Multihash too short. Must be > 3 bytes"]),
ErrTooLong          = NSError(domain: ErrDomain, code: -3, userInfo: [NSLocalizedDescriptionKey : "Multihash too long. Must be < 129 bytes"]),
ErrLenNotSupported  = NSError(domain: ErrDomain, code: -4, userInfo: [NSLocalizedDescriptionKey : "Multihash does not yet support digests longer than 127 bytes"]),
ErrHexFail  = NSError(domain: ErrDomain, code: -5, userInfo: [NSLocalizedDescriptionKey : "Error occurred in hex conversion."])

func ErrInconsistentLen(dm: DecodedMultihash) -> NSError {
        return NSError(domain: ErrDomain, code: -6, userInfo: [NSLocalizedDescriptionKey : "Multihash length inconsistent: \(dm)"])
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
    let code    : Int
    let name    : String
    let length  : Int
    let digest  : [uint8]
}

public struct Multihash {
    let value: [uint8]
}

extension Multihash {
    public func hexString() -> String {
        return Hex.encodeToString(value)
    }
    
    public func string() -> String {
        return self.hexString()
    }
}

func fromHexString(theString: String) -> (Multihash?, NSError?) {
    if let buf = Hex.decodeString(theString) {
        return cast(buf)
    }
    return (nil, ErrHexFail)
}

public func cast(buf: [uint8]) -> (Multihash?, NSError?) {
    let (dm, err) = decode(buf)
    
    if err != nil {
        return (nil, err)
    }
    
    if validCode(dm!.code) == false {
        return (nil,ErrUnknownCode)
    }
    
    return (Multihash(value: buf),nil)
}

public func decode(buf: [uint8]) -> (DecodedMultihash?, NSError?) {

    if buf.count < 3 {
        return (nil, ErrTooShort)
    }
    if buf.count > 129 {
        return (nil, ErrTooLong)
    }

    let dm = DecodedMultihash(code: Int(buf[0]), name: Codes[Int(buf[0])]!, length: Int(buf[1]), digest: Array(buf[2...buf.count]))
    
    if dm.digest.count != dm.length {
        return (nil, ErrInconsistentLen(dm))
    }
    return (dm, nil)
}

/// Encode a hash digest along with the specified function code
/// Note: The length is derived from the length of the digest.
public func encode(buf: [uint8], code: Int?) -> ([uint8]?, NSError?) {

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



// Move this into a hex lib
public struct Hex {
    public static func encodeToString(hexBytes: [uint8]) -> String {
        var outString = ""
        for val in hexBytes {
            outString += String(val, radix: 16)
        }
        return outString
    }

    private static func trimString(theString: String) -> String? {
        let trimmedString = theString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        
        var error: NSError?
        let regex = NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive, error: &error)
        let found = regex?.firstMatchInString(trimmedString, options: nil, range: NSMakeRange(0, count(trimmedString)))
        if found == nil || found?.range.location == NSNotFound || count(trimmedString) % 2 != 0 {
            return nil
        }
        
        return trimmedString
    }

    public static func decodeString(hexString: String) -> [uint8]? {
        
        if let data = NSMutableData(capacity: count(hexString) / 2) {
            
            for var index = hexString.startIndex; index < hexString.endIndex; index = index.successor().successor() {
                let byteString = hexString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
                let num = UInt8(byteString.withCString { strtoul($0, nil, 16)})
                data.appendBytes([num] as [UInt8], length: 1)
            }
            var outBuf = [uint8](count: data.length, repeatedValue: 0x0)
            data.getBytes(&outBuf, length: data.length)
            
            return outBuf
        }
        return nil
    }
}