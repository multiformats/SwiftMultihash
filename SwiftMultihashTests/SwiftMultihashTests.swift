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

struct TestCase {
    let hex     : String
    let code    : Int
    let name    : String
}

extension TestCase {
    func MultiHash() -> (Multihash?, NSError?) {
        if let ob = Hex.decodeString(hex) {
            var b = [uint8](count: ob.count, repeatedValue: 0x0)
            b[0] = uint8(code)
            b[1] = uint8(ob.count)
            b.extend(ob)
            return cast(b)
        } else {
            return (nil, ErrHexFail)
        }
        
    }
}

class SwiftMultihashTests: XCTestCase {
    
    
    let testCases = [
        TestCase(hex: "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33", code: 0x11, name: "sha1"),
        TestCase(hex: "0beec7b5", code: 0x11, name: "sha1"),
        TestCase(hex: "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae", code: 0x12, name: "sha2-256"),
        TestCase(hex: "2c26b46b", code: 0x12, name: "sha2-256")
    ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testEncode() {
        for tc in testCases {
            let ob = Hex.decodeString(tc.hex)
            if ob == nil {
                XCTFail("Hex decodeString failed.")
                continue
            }
            
            var pre: [uint8] = [0,0]
            pre[0] = uint8(tc.code)
            pre[1] = uint8(ob!.count)
            let nb = ob! + pre
            encode()
            
            let (encC, err) = encode(pre, tc.code)
//            if encC == nil {
//                XCTFail("Hex decodeString failed.")
//                continue
//            }
        }
        XCTAssert(true, "Pass")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
