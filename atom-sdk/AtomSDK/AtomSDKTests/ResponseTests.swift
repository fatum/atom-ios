//
//  ResponseTests.swift
//  AtomSDK
//
//  Created by g8y3e on 6/22/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import XCTest
@testable import AtomSDK

class ResponseTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let expectedError = "test error 42"
        let expectedData = "test data 42"
        let expectedStatus = 42
        
        let responseObject = Response(error: expectedError, data: expectedData,
                                      status: expectedStatus)
        
        XCTAssertEqual(expectedError, responseObject.error)
        XCTAssertEqual(expectedData, responseObject.data)
        XCTAssertEqual(expectedStatus, responseObject.status)
    }
}
