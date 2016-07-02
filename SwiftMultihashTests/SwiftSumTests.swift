//
//  SwiftSumTests.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 31/05/15.
//  Licensed under MIT See LICENCE for details 
//

import Foundation
import XCTest
@testable
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
            do {
                let m1: Multihash = try fromHexString(tc.hex)
                let m2: Multihash = try sum(Array(tc.input.utf8), tc.code, tc.length)
                
                if m1 != m2 {
                    XCTFail("sum failed: \(m1.value) \(m2.value)")
                }
                
                let hexStr = m1.hexString()
                if hexStr != tc.hex {
                    XCTFail("Hex strings not the same.")
                }
                
                let b58Str = b58String(m1)
                do {
                    let m3 = try fromB58String(b58Str)
                    if m3 != m1 {
                        XCTFail("b58 failing bytes.")
                    } else if b58Str != b58String(m3) {
                        XCTFail("b58 failing string.")
                    }
                } catch {
                    let error = error as! MultihashError
                    XCTFail("Failed to decode b58.\(error.description)")
                    continue
                }
            } catch  {
                let error = error as! MultihashError
                XCTFail(error.description)
                continue
            }
        }
    }
    
    func testSumPerformance() {
        let tc = sumTestCases[0]
        self.measure {
            do {
                try _ = sum(Array(tc.input.utf8), tc.code, tc.length)
            } catch {}
        }
    }
}
