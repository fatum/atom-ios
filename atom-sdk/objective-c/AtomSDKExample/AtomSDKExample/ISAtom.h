//
//  IronSourceAtom.h
//  AtomSDKExample
//
//  Created by g8y3e on 10/28/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISHttpMethod.h"
#import "ISUtils.h"

/// Atom simple SDK
@interface ISAtom : NSObject
{
    NSMutableDictionary<NSString*, NSString*>* headers_;
    
    BOOL isDebug_;

    NSString* authKey_;
    NSString* endPoint_;
}

@property NSString* authKey;

/**
 *  API Constructor
 *
 *  @return ISAtom
 */
-(id)init;

/**
 *  Enabling print debug information
 *
 *  @param isDebug if set to <c>true</c> is debug.
 */
-(void)enableDebug: (BOOL)isDebug;

/**
 *  Set Auth Key for stream
 *
 *  @param authKey Secret key of stream.
 */
-(void)setAuth: (NSString*)authKey;

/**
 *  Set endpoint for send data
 *
 *  @param endPoint Address of server
 */
-(void)setEndPoint: (NSString*)endPoint;

/**
 *  Send single data to Atom server.
 *
 *  @param stream     Stream name for saving data in db table
 *  @param data       User data to send
 *  @param method     POST or GET method for do request
 *  @param callback   Get response data
 */
-(void)putEventWithStream: (NSString*)stream data: (NSString*)data
                   method: (ISHttpMethod)method
                 callback: (ISRequestCallback)callback;
-(void)putEventWithStream: (NSString*)stream data: (NSString*)NSData
                   method: (ISHttpMethod)method;

/**
 *  Send multiple events data to Atom server.
 *
 *  @param stream     Stream name for saving data in db table
 *  @param data       User data to send
 *  @param callback   Get response data
 */
-(void)putEventsWithStream: (NSString*)stream arrayData: (NSArray*)data
                  callback: (ISRequestCallback)callback;
-(void)putEventsWithStream: (NSString*)stream arrayData: (NSArray*)data;

/**
 *  Send multiple events data to Atom server.
 *
 *  @param stream     Stream name for saving data in db table
 *  @param data       User data to send
 *  @param callback   Get response data
 */
-(void)putEventsWithStream: (NSString*)stream stringData: (NSString*)data
                  callback: (ISRequestCallback)callback;
-(void)putEventsWithStream: (NSString*)stream stringData: (NSString*)data;

/**
 *  Check health of server
 *
 *  @param callback For receive response from server
 */
-(void)healthWithCallback: (ISRequestCallback) callback;
-(void)health;

@end
