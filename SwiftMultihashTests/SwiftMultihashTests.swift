//
//  SwiftMultihashTests.swift
//  SwiftMultihashTests
//
//  Created by Teo on 18/05/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//

import Cocoa
import XCTest
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

struct TestCase {
    let hex     : String
    let code    : Int
    let name    : String
}

extension TestCase {
//    func MultiHash() -> (Multihash?, NSError?) {
    func MultiHash() -> Result<Multihash> {
        if let ob = SwiftHex.decodeString(hex) {
            //var b = [uint8](count: ob.count, repeatedValue: 0x0)
            var b: [uint8] = [0,0]
            b[0] = uint8(code)
            b[1] = uint8(ob.count)
            b.extend(ob)
            return cast(b)
        } else {
            return .Error(ErrHexFail) //(nil, ErrHexFail)
        }
        
    }
}

class SwiftMultihashTests: XCTestCase {
    
    
    let testCases = [
        TestCase(hex: "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33", code: 0x11, name: "sha1"),
        TestCase(hex: "0beec7b5", code: 0x11, name: "sha1"),
        TestCase(hex: "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae", code: 0x12, name: "sha2-256"),
        TestCase(hex: "2c26b46b", code: 0x12, name: "sha2-256"),
        TestCase(hex: "0beec7b5ea3f0fdbc9", code: 0x40, name: "blake2b")
    ]
    
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
            let ob = SwiftHex.decodeString(tc.hex)
            if ob == nil {
                XCTFail("Hex decodeString failed.")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob!.count)
            let nb = pre + ob!
            
            let encC: [uint8]
            switch SwiftMultihash.encode(ob!, tc.code) {
            case .Error(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Value(let val):
                encC = val.unbox
            }
            
            if encC != nb {
               XCTFail("Encoded byte mismatch: \(encC) \(nb)")
            }
            
            let encN: [uint8]
            switch SwiftMultihash.encodeName(ob!, tc.name) {
            case .Error(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Value(let val):
                encN = val.unbox
            }
            if encN != nb {
                XCTFail("Encoded byte mismatch: \(encN) \(nb)")
            }

            switch tc.MultiHash() {
            case .Error(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Value(let val):
                if val.unbox.value != nb {
                    XCTFail("Multihash func mismatch.")
                }
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
            
            let dec: DecodedMultihash
            switch SwiftMultihash.decode(nb) {
            case .Error(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Value(let box):
                dec = box.unbox
            }
            
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
            switch encodeName(buf, "sha1") {
            case .Value(let box):
                let mhbuf = box.unbox
                
                switch decode(mhbuf) {
                case .Value(let box):
                    let o = box.unbox
                    let mhhex = SwiftHex.encodeToString(o.digest)
                    println("obj: \(o.name) \(o.code) \(o.length) \(mhhex)")
                default: break
                }
            default: break
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
            let ob = SwiftHex.decodeString(tc.hex)
            if ob == nil {
                XCTFail("Hex.decodeString failed")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob!.count)
            let nb = pre + ob!

            switch cast(nb) {
            case .Error(let err):
                XCTFail(err.localizedDescription)
                continue
            default: break
            }
            
            switch cast(ob!) {
            case .Value:
                XCTFail("Cast failed to detect non-multihash")
                continue
            default: break
            }
        }
    }
    
    func testHex() {
        for tc in testCases {
            let ob = SwiftHex.decodeString(tc.hex)
            if ob == nil {
                XCTFail("Hex.decodeString failed")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob!.count)
            let nb = pre + ob!
            
            let hs = SwiftHex.encodeToString(nb)
            let mh: Multihash
            switch fromHexString(hs) {
            case .Error(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Value(let box):
                mh = box.unbox
            }
            
            if mh.value != nb {
                XCTFail("FromHexString failed \(nb) \(mh.value)")
                continue
            }

            if mh.hexString() != hs {
                XCTFail("Multihash.HexString failed \(hs) \(mh.hexString())")
                continue
            }
        }
    }
    
    func testEncodePerformance() {
        let tc = testCases[0]
        let ob = SwiftHex.decodeString(tc.hex)
        if ob == nil {
            XCTFail("Hex.decodeString failed")
            return
        }
        
        self.measureBlock() {

            SwiftMultihash.encode(ob!, tc.code)
            
        }
    }

    func testDecodePerformance() {
        let tc = testCases[0]
        let ob = SwiftHex.decodeString(tc.hex)
        if ob == nil {
            XCTFail("Hex.decodeString failed")
            return
        }
        
        var pre: [uint8] = [0,0]
        pre[0] = uint8(tc.code)
        pre[1] = uint8(ob!.count)
        let nb = pre + ob!
        
        self.measureBlock() {
            
            SwiftMultihash.decode(nb)
            
        }
    }
    
}
