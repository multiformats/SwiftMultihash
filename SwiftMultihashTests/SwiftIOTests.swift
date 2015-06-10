//
//  SwiftIOTests.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 04/06/15.
//  Copyright (c) 2015 Matteo Sartori. All rights reserved.
//

import Foundation
import XCTest
@testable
import SwiftMultihash

class SwiftIOTests: XCTestCase {
    
    func testReader() {
        
        let cap = 1024
        var buf = [uint8](count: cap, repeatedValue: 0)
        let outStream = NSOutputStream(toBuffer: &buf, capacity: cap)
        outStream.open()
        // Set up an NSStream we can write to and read from.
        for tc in testCases {
            do {
                let multihash = try tc.multihash()
                if outStream.write(multihash.value, maxLength: multihash.value.count) < 0 {
                    XCTFail("Failed to write to outStream.")
                    return
                }
            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
                return
            }
        }
        
        let inStream = NSInputStream(data: NSData(bytes: buf, length: buf.count))
        inStream.open()
        let reader = newReader(inStream)
        
        for tc in testCases {
            do {
                let testMultihash = try tc.multihash()
                let storedMultihash = try reader.readMultihash()
                
                if storedMultihash != testMultihash {
                    XCTFail("the storedMultihash and the test multihash should be equal.")
                }
            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
                return
            }
        }
    }
    
    
    func testWriter() {
        
        let cap = 1024
        var buf = [uint8](count: cap, repeatedValue: 0)
        let outStream = NSOutputStream(toBuffer: &buf, capacity: cap)
        outStream.open()
        
        let writer = newWriter(outStream)
        
        for tc in testCases {
            do {
                let testMultihash = try tc.multihash()
                try writer.writeMultihash(testMultihash)
                
                var storedMultihash = [uint8](count: testMultihash.value.count, repeatedValue: 0)
                let inStream = NSInputStream(data: NSData(bytes: testMultihash.value, length: testMultihash.value.count))
                inStream.open()
                
                if inStream.read(&storedMultihash, maxLength: buf.count) < 0 {
                    XCTFail("Failed to read from inStream.")
                    continue
                }
                
                if storedMultihash != testMultihash.value {
                    XCTFail("the storedMultihash and the testMultihash should be equal.")
                }

            } catch {
                let error = error as! MultihashError
                XCTFail(error.description)
                return
            }
        }
    }
}