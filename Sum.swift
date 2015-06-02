//
//  Sum.swift
//  SwiftMultihash
//
//  Created by Teo on 30/05/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//

import Foundation
import CryptoSwift

func sumError(code: Int, msg: String) -> NSError {
    return NSError(domain: ErrDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
}

public func sum(data: [uint8], code: Int, length: Int) -> Result<Multihash> {
    
    if validCode(code) == false {
        return .Failure(sumError(-8, "Invalid multihash code \(code)"))
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
        return .Failure(sumError(-7, "Function not implemented. Complain to lib maintainer."))
    }

    var len = length
    
    if len < 0 {
        let dLen = DefaultLengths[code]
        if dLen == nil { return .Failure(sumError(-9, "No default length for code \(code)")) }
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
    let dat = NSData(bytes: data, length: data.count)
    if let bytes = dat.sha1()?.arrayOfBytes() {
        return Array(bytes[0..<20])
    }
    return []
}

func sumSHA256(data: [uint8]) -> [uint8] {
    let dat = NSData(bytes: data, length: data.count)
    if let bytes = dat.sha256()?.arrayOfBytes() {
        return Array(bytes[0..<32])
    }
    return []
}

func sumSHA512(data: [uint8]) -> [uint8] {
    let dat = NSData(bytes: data, length: data.count)
    if let bytes = dat.sha512()?.arrayOfBytes() {
        return Array(bytes[0..<64])
    }
    return []
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
