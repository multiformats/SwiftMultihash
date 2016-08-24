//
//  SwiftIOTests.swift
//  SwiftMultihash
//
//  Created by Matteo Sartori on 04/06/15.
//  Licensed under MIT See LICENCE for details
//

import Foundation
import XCTest
@testable
import SwiftMultihash

class SwiftIOTests: XCTestCase {
    
    func testReader() {
        
        let cap = 1024
        var buf = [UInt8](repeating: 0, count: cap)
        let outStream = OutputStream(toBuffer: &buf, capacity: cap)
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
        
        let inStream = InputStream(data: Data(bytes: UnsafePointer<UInt8>(buf), count: buf.count))
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
        var buf = [UInt8](repeating: 0, count: cap)
        let outStream = OutputStream(toBuffer: &buf, capacity: cap)
        outStream.open()
        
        let writer = newWriter(outStream)
        
        for tc in testCases {
            do {
                let testMultihash = try tc.multihash()
                try writer.writeMultihash(testMultihash)
                
//                var storedMultihash = [UInt8](count: testMultihash.value.count, repeatedValue: 0)
				var storedMultihash = [UInt8](repeating: 0, count: testMultihash.value.count)
                let inStream = InputStream(data: Data(bytes: testMultihash.value, count: testMultihash.value.count))
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
