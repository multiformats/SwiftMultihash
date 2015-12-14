//
//  Sum.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 30/05/15.
//  Licensed under MIT See LICENCE for details 
//

import Foundation
import CommonCrypto

enum MultihashSumError : ErrorType {
    case InvalidMultihash(Int)
    case NotImplemented
    case NoDefaultLength(Int)
}

// English language error descriptions
extension MultihashSumError {
    var description: String {
        get {
            switch self {
            case .InvalidMultihash(let code):
                return "Invalid multihash code \(code)"
            case .NotImplemented:
                return "Function not implemented. Complain to lib maintainer."
            case .NoDefaultLength(let code):
                return "No default length for code \(code)"
            }
        }
    }
}

//func sumError(code: Int, msg: String) -> NSError {
//    return NSError(domain: ErrDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
//}

public func sum(data: [UInt8], _ code: Int, _ length: Int) throws -> Multihash {
    
    if validCode(code) == false {
        throw MultihashSumError.InvalidMultihash(code)
    }
    
    var sumData: [UInt8]
    switch code {
    case SHA1:
        sumData = sumSHA1(data)
    case SHA2_256:
        sumData = sumSHA256(data)
    case SHA2_512:
        sumData = sumSHA512(data)
    default:
        throw MultihashSumError.NotImplemented
    }

    var len: Int = length
    
    if length < 0 {
        guard let l = DefaultLengths[code] else {
            throw MultihashSumError.NoDefaultLength(code)
        }
        len = l
    }
    
    let bytes: [UInt8] = Array(sumData[0..<len])

    return Multihash(try SwiftMultihash.encodeBuf(bytes,code: code))
}

func sumSHA1(data: [UInt8]) -> [UInt8] {

    let len = Int(CC_SHA1_DIGEST_LENGTH)
    var digest = [UInt8](count: len, repeatedValue: 0)
    
    CC_SHA1(data, CC_LONG(data.count), &digest)
    
    return Array(digest[0..<len])
}

func sumSHA256(data: [UInt8]) -> [UInt8] {
    
    let len = Int(CC_SHA256_DIGEST_LENGTH)
    var digest = [UInt8](count: len, repeatedValue: 0)
    
    CC_SHA256(data, CC_LONG(data.count), &digest)
    
    return Array(digest[0..<len])
}

func sumSHA512(data: [UInt8]) -> [UInt8] {
    
    let len = Int(CC_SHA512_DIGEST_LENGTH)
    var digest = [UInt8](count: len, repeatedValue: 0)
    
    CC_SHA512(data, CC_LONG(data.count), &digest)
    
    return Array(digest[0..<len])
}

// No SHA3 Swift lib yet?
//func sumSHA3(data: [UInt8]) -> [UInt8] {
//    let dat = NSData(bytes: data, length: data.count)
//
//    if let bytes = dat. no sha3  ?.arrayOfBytes() {
//        return Array(bytes[0..<20])
//    }
//    return []
//}
