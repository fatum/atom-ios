//
//  BatchTests.swift
//  AtomSDK
//
//  Created by g8y3e on 6/22/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import XCTest
@testable import AtomSDK

class BatchTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let expectedEvents = ["test 1", "test 2"]
        let expectedId: Int32 = 42
        
        let batchObject = Batch(events: expectedEvents, lastId: expectedId)
        
        XCTAssertEqual(expectedId, batchObject.lastId)
        XCTAssertEqual(expectedEvents.count, batchObject.events.count)
        
        for i in 0...(expectedEvents.count - 1) {
            XCTAssertEqual(expectedEvents[i], batchObject.events[i])
        }
    }
}
