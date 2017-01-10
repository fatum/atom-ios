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
 * @brief High Level - The tracker is used for sending events to Atom based on several conditions:
 * Every interval, Every X Bytes accumulated or every X (count) of events accumulated
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
 *  SKD Tracker constructor
 *
 *  @return ISAtomTracker
 */
-(id)init;

/**
 *  SDK Tracker destructor
 */
-(void)dealloc;

/**
 *  Enabling printing of debug information
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
 *  Set Atom API EndPoint for sending data
 *
 *  @param endPoint Address of the server
 */
-(void)setEndPoint: (NSString*)endPoint;

/**
 *  Set Bulk size (number of events in a bulk)
 *
 *  @param bulkSize Count of event for flush
 */
-(void)setBulkSize: (int)bulkSize;

/**
 *  Set Bulk size in bytes
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
 *  @param stream Atom Stream name
 *  @param data Data to send
 *  @param token Secret hmac auth key of stream
 */
-(void)trackWithStream: (NSString*)stream data: (NSString*)data
                 token: (NSString*)token;

/**
 *  Track data to server
 *
 *  @param stream Atom Stream name
 *  @param data Data to send
 */
-(void)trackWithStream: (NSString*)stream data: (NSString*)data;

/**
 *  Flush specific stream data to server
 *
 *  @param stream Name of the stream
 */
-(void)flushWithStream: (NSString*)stream;

/**
 *  Flush data to server
 */
-(void)flush;

@end
