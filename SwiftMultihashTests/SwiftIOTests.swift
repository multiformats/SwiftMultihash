//
//  SwiftIOTests.swift
//  SwiftMultihash
//
//  Created by Teo on 04/06/15.
//  Copyright (c) 2015 Teo. All rights reserved.
//

import Foundation
import XCTest
import SwiftMultihash

class SwiftIOTests: XCTestCase {
    
    func testReader() {
        
        let cap = 1024
        var buf = [uint8](count: cap, repeatedValue: 0)
        var outStream = NSOutputStream(toBuffer: &buf, capacity: cap)
        outStream.open()
        // Set up an NSStream we can write to and read from.
        for tc in testCases {
            let result = tc.multihash()
            switch result {
            case .Failure(let err):
                XCTFail(err.localizedDescription)
                return
            case .Success(let box):
                let multihash = box.unbox
                if outStream.write(multihash.value, maxLength: multihash.value.count) < 0 {
                    XCTFail("Failed to write to outStream.")
                    return
                }
            }
        }
        
        var inStream = NSInputStream(data: NSData(bytes: buf, length: buf.count))
        inStream.open()
        let reader = newReader(inStream)
        
        for tc in testCases {
            switch tc.multihash() {
            case .Failure(let err):
                XCTFail(err.localizedDescription)
                return
            case .Success(let box):
                
                let testMultihash = box.unbox
                
                switch reader.readMultihash() {
                case .Failure(let err):
                    XCTFail(err.localizedDescription)
                    continue
                case .Success(let box):
                    let storedMultihash = box.unbox
                    if storedMultihash != testMultihash {
                        XCTFail("the storedMultihash and the test multihash should be equal.")
                    }
                }
                
            }
        }
    }
    
    
    func testWriter() {
        
        let cap = 1024
        var buf = [uint8](count: cap, repeatedValue: 0)
        var outStream = NSOutputStream(toBuffer: &buf, capacity: cap)
        outStream.open()
        
        let writer = newWriter(outStream)
        
        for tc in testCases {
            switch tc.multihash() {
            case .Failure(let err):
                XCTFail(err.localizedDescription)
                continue
            case .Success(let box):
                let testMultihash = box.unbox
                if let err = writer.writeMultihash(testMultihash) {
                    XCTFail(err.localizedDescription)
                    continue
                }
                
                var storedMultihash = [uint8](count: testMultihash.value.count, repeatedValue: 0)
                var inStream = NSInputStream(data: NSData(bytes: testMultihash.value, length: testMultihash.value.count))
                inStream.open()
                
                if inStream.read(&storedMultihash, maxLength: buf.count) < 0 {
                    XCTFail("Failed to read from inStream.")
                    continue
                }
                
                if storedMultihash != testMultihash.value {
                    XCTFail("the storedMultihash and the testMultihash should be equal.")
                }
            }
        }
    }
}