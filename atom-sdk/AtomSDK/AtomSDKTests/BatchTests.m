//
//  BatchTests.m
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 12/12/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <XCTest/XCTest.h>

@import AtomSDK;

@interface BatchTests : XCTestCase

@end

@implementation BatchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSArray* expectedEvents = [NSArray arrayWithObjects: @"test 1", @"test 2", nil];
    int expectedId = 42;
}

@end
