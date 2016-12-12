//
//  ISStreamDataTests.m
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 12/12/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../AtomSDK/ISStreamData.h"

@interface ISStreamDataTests : XCTestCase

@end

@implementation ISStreamDataTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    NSString* expectedName = @"testName";
    NSString* expectedToken = @"42rrrrr42";
    
    ISStreamData* streamDataObject = [[ISStreamData alloc] initWithName:expectedName
                                                                  token:expectedToken];
    
    XCTAssertEqual(expectedName, [streamDataObject name]);
    XCTAssertEqual(expectedToken, [streamDataObject token]);
}

@end
