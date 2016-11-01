//
//  StreamDataTests.swift
//  AtomSDK
//
//  Created by g8y3e on 6/22/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import XCTest
@testable import AtomSDK

class StreamDataTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let expectedName = "testName"
        let expectedToken = "42rrrrr42"
        
        let streamDataObject = StreamData(name: expectedName, token: expectedToken)
        
        XCTAssertEqual(expectedName, streamDataObject.name)
        XCTAssertEqual(expectedToken, streamDataObject.token)
    }
}
