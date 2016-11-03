//
//  IronSourceAtom.m
//  AtomSDKExample
//
//  Created by g8y3e on 10/28/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISAtom.h"

#import "ISRequest.h"

@interface ISAtom()

-(NSString*)getRequestDataWithStream: (NSString*)stream
                                data: (NSString*)data
                              isBulk: (BOOL)isBulk;
-(void)sendRequestWithUrl: (NSString*)url data: (NSString*)data
                   method: (ISHttpMethod)method
                 callback: (ISRequestCallback) callback;

-(void)printLog: (NSString*)logData;
@end

static NSString* DEFAULT_ENDPOINT_ = @"http://track.atom-data.io/";
static NSString* VERSION_ = @"V1.0.0";

@implementation ISAtom

-(id)init {
    self = [super init];
    
    if (self) {
        self->endPoint_ = DEFAULT_ENDPOINT_;
        
        headers_ = [[NSMutableDictionary alloc] init];
        
        [headers_ setObject:@"ios" forKey:@"x-ironsource-atom-sdk-type"];
        [headers_ setObject:VERSION_ forKey:@"x-ironsource-atom-sdk-version"];
        [headers_ setObject:@"application/json" forKey:@"Content-type"];
    }
    
    return self;
}

-(void)enableDebug: (BOOL)isDebug {
    isDebug_ = isDebug;
}

-(void)setAuth: (NSString*)authKey {
    authKey_ = authKey;
}

-(void)setEndPoint: (NSString*)endPoint {
    endPoint_ = endPoint;
}

-(void)putEventWithStream: (NSString*)stream data: (NSString*)data
                   method: (ISHttpMethod)method
                 callback: (ISRequestCallback) callback {
    [self printLog:@"Run put event!"];
    NSString* jsonData = [self getRequestDataWithStream:stream data: data
                                                 isBulk:false];
    
    [self sendRequestWithUrl:self->endPoint_ data:jsonData method:method
                    callback:callback];
}

-(void)putEventWithStream: (NSString*)stream data: (NSString*)data
                   method: (ISHttpMethod)method {
    [self putEventWithStream:stream data:data method:method callback:nil];
}

-(void)putEventsWithStream: (NSString*)stream arrayData: (NSArray*)data
                  callback: (ISRequestCallback)callback {
    NSString* listJson = [ISUtils listToJsonStr:data];
    
    [self printLog:[NSString stringWithFormat:@"List to json: %@", listJson]];
    
    NSString* jsonData = [self getRequestDataWithStream:stream data:listJson
                                                 isBulk:true];

    [self sendRequestWithUrl:[NSString stringWithFormat:@"%@bulk", self->endPoint_]
                        data:jsonData method:IS_POST callback:callback];
}

-(void)putEventsWithStream: (NSString*)stream arrayData: (NSArray*)data {
    [self putEventsWithStream:stream arrayData:data callback:nil];
}

-(void)putEventsWithStream: (NSString*)stream stringData: (NSString*)data
                  callback: (ISRequestCallback)callback {
    NSString* jsonData = [self getRequestDataWithStream:stream data:data
                                                 isBulk:true];
    
    [self sendRequestWithUrl:[NSString stringWithFormat:@"%@bulk", self->endPoint_]
                        data:jsonData method:IS_POST callback:callback];
    
}

-(void)putEventsWithStream: (NSString*)stream stringData: (NSString*)data {
    [self putEventsWithStream:stream stringData:data callback:nil];
}

-(void)healthWithCallback: (ISRequestCallback)callback {
    [self sendRequestWithUrl:[NSString stringWithFormat:@"%@health", self->endPoint_]
                        data:@"" method:IS_GET callback:callback];
}

-(void)health {
    [self healthWithCallback:nil];
}

-(NSString*)getRequestDataWithStream: (NSString*)stream data: (NSString*)data
                              isBulk: (BOOL)isBulk {
    NSString* hash = ([self->authKey_ length] == 0) ? @"" :
            [ISUtils encodeHMACWithInput:data key:self->_authKey];
    
    NSMutableDictionary* eventObject = [[NSMutableDictionary<NSString*, NSObject*>
                                         alloc] init];
    [eventObject setObject:stream forKey:@"table"];
    [eventObject setObject:data forKey:@"data"];
    if ([hash length] != 0) {
        [eventObject setObject:hash forKey:@"auth"];
    }
    if (isBulk) {
        [eventObject setObject:[NSNumber numberWithBool:isBulk] forKey:@"bulk"];
    }
    
    NSString* jsonStr = [ISUtils objectToJsonStr:eventObject];
    
    [self printLog:[NSString stringWithFormat:@"Request json: %@", jsonStr]];
    
    return jsonStr;
}

-(void)sendRequestWithUrl: (NSString*)url data:(NSString*)data
                   method:(ISHttpMethod)method
                 callback:(ISRequestCallback)callback {
    ISRequest* request = [[ISRequest alloc] initWithUrl:url data:data
                                                headers:self->headers_
                                               callback:callback
                                                isDebug:self->isDebug_];
    
    if (method == IS_GET) {
        [request get];
    } else {
        [request post];
    }
}

-(void)printLog: (NSString*)logData {
    if (self->isDebug_) {
        NSLog(@"%@: %@",  NSStringFromClass([self class]), logData);
    }
}

@end
