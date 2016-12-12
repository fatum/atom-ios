//
//  ISAtomTracker.h
//  AtomSDK
//
//  Created by g8y3e on 11/3/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISAtom.h"

/*!
 * @brief API Tracker class - for flush data in intervals
 */
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
    
    dispatch_semaphore_t semaphore_;
}

/**
 *  API Tracker constructor
 *
 *  @return ISAtomTracker
 */
-(id)init;

/**
 *  API Tracker destructor
 */
-(void)dealloc;

/**
 *  Enabling print debug information
 *
 *  @param isDebug if set to <c>true</c> is debug.
 */
-(void)enableDebug: (BOOL)isDebug;

/**
 *  Set Auth Key for stream
 *
 *  @param authKey Secret key of stream
 */
-(void)setAuth: (NSString*)authKey;

/**
 *  Set EndPoint for send data
 *
 *  @param endPoint Address of the server
 */
-(void)setEndPoint: (NSString*)endPoint;

/**
 *  Set Bulk data count
 *
 *  @param bulkSize Count of event for flush
 */
-(void)setBulkSize: (int)bulkSize;

/**
 *  Set Bulk data bytes size
 *
 *  @param bulkBytesSize Size in bytes
 */
-(void)setBulkBytesSize: (int)bulkBytesSize;

/**
 *  Set intervals for flushing data
 *
 *  @param flushInterval Intervals in seconds
 */
-(void)setFlushInterval: (double)flushInterval;

/**
 *  Track data to server
 *
 *  @param stream Name of the stream
 *  @param data Info for sending
 *  @param token Secret key of stream
 */
-(void)trackWithStream: (NSString*)stream data: (NSString*)data
                 token: (NSString*)token;

/**
 *  Track data to server
 *
 *  @param stream Name of the stream
 *  @param data Info for sending
 */
-(void)trackWithStream: (NSString*)stream data: (NSString*)data;

/**
 *  Flush data to server of specific stream
 *
 *  @param stream Name of the stream
 */
-(void)flushWithStream: (NSString*)stream;

/**
 *  Flush data to server of specific stream
 */
-(void)flush;

@end
