//
//  UtilsTests.swift
//  AtomSDK
//
//  Created by g8y3e on 6/22/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import XCTest

import Arcane
@testable import AtomSDK

class UtilsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testObjectToJsonStr() {
        let expectStr = "{\"test\":\"test 42\"}"
        
        var testObject = Dictionary<String, String>()
        testObject["test"] = "test 42"
        
        let resultStr = ObjectToJsonStr(testObject)
        
        XCTAssertEqual(expectStr, resultStr)
        
        
        var testOErrorbject = Dictionary<String, String>()
        let bogusStr = String(
            bytes: [0xD8, 0x00] as [UInt8],
            encoding: NSUTF16BigEndianStringEncoding)!
        
        testOErrorbject["test"] = bogusStr
        let resultErrorStr = ObjectToJsonStr(testOErrorbject)
        
        XCTAssertEqual("", resultErrorStr)
    }
    
    func testListToJsonStr() {
        let expectedStr = "[{\"test\":\"test 42\"}]"
        let resultStr = ListToJsonStr(["{\"test\":\"test 42\"}"])
        
        XCTAssertEqual(expectedStr, resultStr)
    }
    
    func testEncodeHmac() {
        let expectedStr = "76307206843c59be2d6de433c54322fb2060dbb3400b387cca6a6bc2feb6d1f3"
        
        let key = "fkfkmfkfkfkd"
        let value = "test 42"
        
        let resultStr = EncodeHmac(value, key: key)
        
        XCTAssertEqual(expectedStr, resultStr)
    }

    func testCurrentTimeMillis() {
        let previousTime = CurrentTimeMillis()
        NSThread.sleepForTimeInterval(0.1)
        let currentTime = CurrentTimeMillis()
        
        XCTAssertNotEqual(previousTime, currentTime)
    }

}
