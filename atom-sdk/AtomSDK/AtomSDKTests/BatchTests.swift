//
//  BatchTests.swift
//  AtomSDK
//
//  Created by g8y3e on 6/17/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import XCTest

import AtomSDK

class BatchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreation() {
        let expectedList = ["1", "2", "3"]
        let expectedId: Int32 = 42
        
        let batch = Batch(events: expectedList, lastId: expectedId)
        
        XCTAssert(expectedList == batch.events)
        XCTAssert(expectedId == batch.lastId)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
