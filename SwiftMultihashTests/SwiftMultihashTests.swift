//
//  SwiftMultihashTests.swift
//  SwiftMultihashTests
//
//  Created by Matteo Sartori on 18/05/15.
//  Copyright (c) 2015 Matteo Sartori. All rights reserved.
//

import Cocoa
import XCTest
@testable
import SwiftMultihash
import SwiftHex

let tCodes = [
    0x11: "sha1",
    0x12: "sha2-256",
    0x13: "sha2-512",
    0x14: "sha3",
    0x40: "blake2b",
    0x41: "blake2s",
]

public struct TestCase {
    let hex     : String
    let code    : Int
    let name    : String
}

public let testCases = [
    TestCase(hex: "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33", code: 0x11, name: "sha1"),
    TestCase(hex: "0beec7b5", code: 0x11, name: "sha1"),
    TestCase(hex: "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae", code: 0x12, name: "sha2-256"),
    TestCase(hex: "2c26b46b", code: 0x12, name: "sha2-256"),
    TestCase(hex: "0beec7b5ea3f0fdbc9", code: 0x40, name: "blake2b")
]

public extension TestCase {

    func multihash() throws -> Multihash {
        if let ob = SwiftHex.decodeString(hex) {

            var b: [uint8] = [0,0]
            b[0] = uint8(code)
            b[1] = uint8(ob.count)
            b.extend(ob)
            return try cast(b)
        } else {
            throw MultihashError.HexConversionFail
        }
        
    }
}

class SwiftMultihashTests: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEncode() {
        for tc in testCases {
            guard let ob = SwiftHex.decodeString(tc.hex) else {
                XCTFail("Hex decodeString failed.")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob.count)
            let nb = pre + ob
            do {
                let encC: [uint8] = try SwiftMultihash.encodeBuf(ob, code: tc.code)
                if encC != nb {
                    XCTFail("Encoded byte mismatch: \(encC) \(nb)")
                }

                let encN: [uint8] = try SwiftMultihash.encodeName(ob, name: tc.name)
                if encN != nb {
                    XCTFail("Encoded byte mismatch: \(encN) \(nb)")
                }
                
                let val = try tc.multihash()
                if val.value != nb {
                    XCTFail("Multihash func mismatch.")
                }
                
            } catch {
                let err = error as! MultihashError
                XCTFail(err.description)
                continue
            }
        }
        XCTAssert(true, "Pass")
    }
    
    func testDecode() {
        for tc in testCases {
            let ob = SwiftHex.decodeString(tc.hex)
            if ob == nil {
                XCTFail("Hex decodeString failed.")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob!.count)
            let nb = pre + ob!
            do {
                let dec: DecodedMultihash = try SwiftMultihash.decodeBuf(nb)
                
                if dec.code != tc.code {
                    XCTFail("Decoded code mismatch: \(dec.code) \(tc.code)")
                }
                
                if dec.name != tc.name {
                    XCTFail("Decoded name mismatch: \(dec.name) \(tc.name)")
                }
                
                if dec.length != ob!.count {
                    XCTFail("Decoded length mismatch: \(dec.length) \(ob!.count)")
                }
                
                if dec.digest != ob! {
                    XCTFail("Decoded byte mismatch: \(dec.digest) \(ob!)")
                }

            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
                continue
            }
        }
        XCTAssert(true, "Pass")
    }
    
    func testTable() {
        for (k, v) in tCodes {
            if Codes[k] != v {
                XCTFail("Table mismatch: \(Codes[k]) \(v)")
            }
            if Names[v] != k {
                XCTFail("Table mismatch: \(Names[v]) \(k)")
            }
        }
    }
    
    func testExampleDecode() {

        if let buf = SwiftHex.decodeString("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33") {
            do {
                let mhbuf = try encodeName(buf, name: "sha1")
                let o = try decodeBuf(mhbuf)
                    
                let mhhex = SwiftHex.encodeToString(o.digest)
                print("obj: \(o.name) \(o.code) \(o.length) \(mhhex)")
            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
            }
        }
    }
    
    func testValidCode() {
        for i in 0..<0xff {
            let ok = tCodes[i]
            let b = appCode(i) || (ok != nil)
            if validCode(i) != b {
                XCTFail("ValidCode incorrect for: \(i)")
            }
        }
    }
    
    func testAppCode() {
        for i in 0..<0xff {
            let b = i >= 0 && i < 0x10
            if appCode(i) != b {
                XCTFail("AppCode incorrect for: \(i)")
            }
        }
    }
    
    func testCast() {
        for tc in testCases {
            guard let ob = SwiftHex.decodeString(tc.hex) else {
                XCTFail("Hex.decodeString failed")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob.count)
            let nb = pre + ob

            do {
                try cast(nb)
            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
                continue

            }
            
            do {
                try cast(ob)
                XCTFail("Cast failed to detect non-multihash")
                continue
            } catch {
            }
        }
    }
    
    func testHex() {
        for tc in testCases {
            guard let ob = SwiftHex.decodeString(tc.hex) else {
                XCTFail("Hex.decodeString failed")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob.count)
            let nb = pre + ob
            
            let hs = SwiftHex.encodeToString(nb)
            do {
                let mh: Multihash = try fromHexString(hs)
                
                if mh.value != nb {
                    XCTFail("FromHexString failed \(nb) \(mh.value)")
                    continue
                }
                
                if mh.hexString() != hs {
                    XCTFail("Multihash.HexString failed \(hs) \(mh.hexString())")
                    continue
                }
            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
                continue
            }
        }
    }
    
    func testEncodePerformance() {
        let tc = testCases[0]
        guard let ob = SwiftHex.decodeString(tc.hex) else {
            XCTFail("Hex.decodeString failed")
            return
        }
        
        self.measureBlock() {
            do {
            try SwiftMultihash.encodeBuf(ob, code: tc.code)
            } catch { }
        }
    }

    func testDecodePerformance() {
        let tc = testCases[0]
        guard let ob = SwiftHex.decodeString(tc.hex) else {
            XCTFail("Hex.decodeString failed")
            return
        }
        
        var pre: [uint8] = [0,0]
        pre[0] = uint8(tc.code)
        pre[1] = uint8(ob.count)
        let nb = pre + ob
        
        self.measureBlock() {
            do {
                try SwiftMultihash.decodeBuf(nb)
            } catch {
                XCTFail("SwiftMultihash.decodeBuf failed")
            }
        }
    }
    
}
