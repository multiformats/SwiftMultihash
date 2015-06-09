//
//  SwiftSumTests.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 31/05/15.
//  Copyright (c) 2015 Matteo Sartori. All rights reserved.
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

            let m1: Multihash
            switch fromHexString(tc.hex) {
            case .Failure(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Success(let val):
                m1 = val
            }
            
            let m2: Multihash
            switch sum(Array(tc.input.utf8), tc.code, tc.length) {
            case .Failure(let err):
                XCTFail("\(tc.code) sum failed. \(err.localizedDescription)")
                continue
            case .Success(let val):
                m2 = val
            }

            if m1 != m2 {
                XCTFail("sum failed: \(m1.value) \(m2.value)")
            }
            
            let hexStr = m1.hexString()
            if hexStr != tc.hex {
                XCTFail("Hex strings not the same.")
            }
            
            let b58Str = b58String(m1)
            
            switch fromB58String(b58Str) {
            case .Failure(let err):
                XCTFail("Failed to decode b58.\(err)")
            case .Success(let val):
                let m3 = val
                if m3 != m1 {
                    XCTFail("b58 failing bytes.")
                } else if b58Str != b58String(m3) {
                    XCTFail("b58 failing string.")
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