//
//  Sum.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 30/05/15.
//  Copyright (c) 2015 Matteo Sartori. All rights reserved.
//

import Foundation
//import CryptoSwift
import CommonCrypto

func sumError(code: Int, msg: String) -> NSError {
    return NSError(domain: ErrDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
}

public func sum(data: [uint8], _ code: Int, _ length: Int) -> Result<Multihash> {
    
    if validCode(code) == false {
        return .Failure(sumError(-8, msg: "Invalid multihash code \(code)"))
    }
    
    var sumData: [uint8]
    switch code {
    case SHA1:
        sumData = sumSHA1(data)
    case SHA2_256:
        sumData = sumSHA256(data)
    case SHA2_512:
        sumData = sumSHA512(data)
    default:
        return .Failure(sumError(-7, msg: "Function not implemented. Complain to lib maintainer."))
    }

    var len = length
    
    if len < 0 {
        let dLen = DefaultLengths[code]
        if dLen == nil { return .Failure(sumError(-9, msg: "No default length for code \(code)")) }
        len = dLen!
    }
    
    let bytes: [uint8] = Array(sumData[0..<len])

    let result = SwiftMultihash.encode(bytes,code)
    switch result {
    case .Success(let encBytes):
        return .Success(Box(Multihash(encBytes.unbox)))
    case .Failure(let err):
        return .Failure(err)
     }
}

func sumSHA1(data: [uint8]) -> [uint8] {

    let len = Int(CC_SHA1_DIGEST_LENGTH)
    var digest = [uint8](count: len, repeatedValue: 0)
    
    CC_SHA1(data, CC_LONG(data.count), &digest)
    
    return Array(digest[0..<len])
}

func sumSHA256(data: [uint8]) -> [uint8] {
    
    let len = Int(CC_SHA256_DIGEST_LENGTH)
    var digest = [uint8](count: len, repeatedValue: 0)
    
    CC_SHA256(data, CC_LONG(data.count), &digest)
    
    return Array(digest[0..<len])
}

func sumSHA512(data: [uint8]) -> [uint8] {
    
    let len = Int(CC_SHA512_DIGEST_LENGTH)
    var digest = [uint8](count: len, repeatedValue: 0)
    
    CC_SHA512(data, CC_LONG(data.count), &digest)
    
    return Array(digest[0..<len])
}

// No SHA3 Swift lib yet?
//func sumSHA3(data: [uint8]) -> [uint8] {
//    let dat = NSData(bytes: data, length: data.count)
//
//    if let bytes = dat. no sha3  ?.arrayOfBytes() {
//        return Array(bytes[0..<20])
//    }
//    return []
//}
