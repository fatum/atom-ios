//
//  BatchTests.m
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 12/12/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../AtomSDK/ISBatch.h"

@interface ISBatchTests : XCTestCase

@end

@implementation ISBatchTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    NSArray* expectedEvents = [NSArray arrayWithObjects: @"test 1", @"test 2", nil];
    int expectedId = 42;
    
    ISBatch* batchObject = [[ISBatch alloc] initWithEvents:expectedEvents lastID:expectedId];
    
    XCTAssertEqual(expectedId, [batchObject lastID]);
    XCTAssertEqual(expectedEvents.count, [[batchObject events] count]);
    
    for (int i = 1; i <= (expectedEvents.count - 1); i++) {
        XCTAssertEqual(expectedEvents[i], [batchObject events][i]);
    }
}

@end
