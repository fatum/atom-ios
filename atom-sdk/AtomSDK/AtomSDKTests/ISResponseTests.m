//
//  ISResponseTests.m
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 12/12/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../AtomSDK/ISResponse.h"

@interface ISResponseTests : XCTestCase

@end

@implementation ISResponseTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    NSString* expectedError = @"test error 42";
    NSString* expectedData = @"test data 42";
    int expectedStatus = 42;
    
    ISResponse* responseObject = [[ISResponse alloc] initWithData:expectedData
                                                            error:expectedError
                                                           status:expectedStatus];
    XCTAssertEqual(expectedError, [responseObject error]);
    XCTAssertEqual(expectedData, [responseObject data]);
    XCTAssertEqual(expectedStatus, [responseObject status]);
}

@end
