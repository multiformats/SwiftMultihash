//
//  SwiftSumTests.swift
//  SwiftMultihash
//
//  Created by Teo on 31/05/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//

import Foundation
import XCTest
import SwiftMultihash

struct SumTestCase {
    let code: Int
    let length: Int
    let input: String
    let hex: String
}

let sumTestCases = [
    SumTestCase(code: SHA1, length: -1, input: "foo", hex: "11140beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33"),
    SumTestCase(code: SHA1, length: 10, input: "foo", hex: "110a0beec7b5ea3f0fdbc95d"),
    SumTestCase(code: SHA2_256, length: -1, input: "foo", hex: "12202c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae"),
    SumTestCase(code: SHA2_256, length: 16, input: "foo", hex: "12102c26b46b68ffc68ff99b453c1d304134"),
    SumTestCase(code: SHA2_512, length: -1, input: "foo", hex: "1340f7fbba6e0636f890e56fbbf3283e524c6fa3204ae298382d624741d0dc6638326e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7"),
    SumTestCase(code: SHA2_512, length: 32, input: "foo", hex: "1320f7fbba6e0636f890e56fbbf3283e524c6fa3204ae298382d624741d0dc663832")
]

class SwiftSumTests: XCTestCase {
    
    func testSum() {
        for tc in sumTestCases {
            var err: NSError
            let (m1, errm1) = fromHexString(tc.hex)
            if let err = errm1 {
                XCTFail(err.localizedDescription)
                continue
            }
            
            let (m2, errm2) = sum(Array(tc.input.utf8), tc.code, tc.length)
            if let err = errm2 {
                XCTFail("\(tc.code) sum failed. \(err.localizedDescription)")
            }
            // clumsy unwrapping - Bleh, Swift!
            if let m1 = m1, m2 = m2 {
                if m1 != m2 {
                    XCTFail("sum failed: \(m1.value) \(m2.value)")
                }
                
                let hexStr = m1.hexString()
                if hexStr != tc.hex {
                    XCTFail("Hex strings not the same.")
                }
                
                let b58Str = b58String(m1)
                let (m3, errm3) = fromB58String(b58Str)
                if let m3 = m3 {
                    if m3 != m1 {
                        XCTFail("b58 failing bytes.")
                    } else if b58Str != b58String(m3) {
                        XCTFail("b58 failing string.")
                    }
                } else {
                    XCTFail("Failed to decode b58.")
                }
            }
        }
    }
    
    func testSumPerformance() {
        let tc = sumTestCases[0]
        self.measureBlock {
            sum(Array(tc.input.utf8), tc.code, tc.length)
        }
    }
}