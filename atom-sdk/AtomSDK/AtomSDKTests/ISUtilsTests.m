//
//  ISUtilsTests.m
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 12/12/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../AtomSDK/ISUtils.h"

@interface ISUtilsTests : XCTestCase

@end

@implementation ISUtilsTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testObjectToJsonStr {
    NSString* expectStr = @"{\"test\":\"test 42\"}";
    
    NSMutableDictionary<NSString*, NSString*>* testObject = [[NSMutableDictionary alloc] init];
    [testObject setValue:@"test 42" forKey:@"test"];
    
    NSString* resultStr = [ISUtils objectToJsonStr:testObject];
    
    XCTAssertTrue([expectStr isEqualToString:resultStr]);
    
    NSMutableDictionary<NSString*, NSString*>* testErrorObject = [[NSMutableDictionary alloc] init];
    
    uint8_t buffer[2];
    buffer[0] = 0xD8;
    buffer[1] = 0x00;
    
    NSString* bogusStr = [[NSString alloc] initWithBytes:buffer
                                                  length:2
                                                encoding:NSUTF16BigEndianStringEncoding];
    
    [testErrorObject setValue:bogusStr forKey:@"test"];
    
    NSString* resultErrorStr = [ISUtils objectToJsonStr:testErrorObject];
    
    XCTAssertTrue([resultErrorStr isEqualToString:@""]);
}

- (void)testListToJsonStr {
    NSString* expectedStr = @"[{\"test\":\"test 42\"}]";
    NSString* resultStr = [ISUtils listToJsonStr:[NSArray arrayWithObjects:@"{\"test\":\"test 42\"}", nil]];
    
    XCTAssertTrue([expectedStr isEqualToString:resultStr]);
}

- (void)testEncodeHmac {
    NSString* expectedStr = @"76307206843c59be2d6de433c54322fb2060dbb3400b387cca6a6bc2feb6d1f3";
    
    NSString* key = @"fkfkmfkfkfkd";
    NSString* value = @"test 42";
    
    NSString* resultStr = [ISUtils encodeHMACWithInput:value key:key];
    
    XCTAssertTrue([expectedStr isEqualToString:resultStr]);
}

- (void)testCurrentTimeMillis {
    int64_t previousTime = [ISUtils currentTimeMillis];
    [NSThread sleepForTimeInterval:0.1];
    int64_t currentTime = [ISUtils currentTimeMillis];
    
    XCTAssertNotEqual(previousTime, currentTime);
}

@end
