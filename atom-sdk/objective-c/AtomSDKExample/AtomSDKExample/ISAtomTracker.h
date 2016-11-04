//
//  ISAtomTracker.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/3/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISAtom.h"
#import "ISDatabaseAdapter.h"

@interface ISAtomTracker : NSObject
{
    double flushInterval_;
    int bulkSize_;
    int bulkBytesSize_;
    
    NSTimer* timer_;
    
    ISAtom* api_;
    
    BOOL isDebug_;
    BOOL isFirst_;
    BOOL isRunTimeFlush_;
    
    NSLock* flushSizedLock_;
    NSLock* flushLock_;
    
    NSMutableDictionary<NSString*, NSNumber*>* isFlushSizedRunned_;
    NSMutableDictionary<NSString*, NSNumber*>* isFlushRunned_;
    
    ISDatabaseAdapter* database_;
    
    dispatch_semaphore_t semaphore_;
}

-(id)init;

-(void)dealloc;

-(void)enableDebug: (BOOL)isDebug;

-(void)setAuth: (NSString*)authKey;

-(void)setEndPoint: (NSString*)endPoint;

-(void)setBulkSize: (int)bulkSize;

-(void)setBulkBytesSize: (int)bulkBytesSize;

-(void)setFlushInterval: (double)flushInterval;

-(void)trackWithStream: (NSString*)stream data: (NSString*)data
                 token: (NSString*)token;

-(void)flushWithStream: (NSString*)stream;
-(void)flush;

@end
