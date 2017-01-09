//
//  IronSourceAtom.h
//  AtomSDK
//
//  Created by g8y3e on 10/28/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISUtils.h"

/*!
 * @brief Atom simple SDK
 */
@interface ISAtom : NSObject
{
    NSMutableDictionary<NSString*, NSString*>* headers_;
    
    BOOL isDebug_;

    NSMutableString* authKey_;
    NSMutableString* endPoint_;
}

/*!
 * @brief Secret Auth key
 */
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
 *  @param isDebug if set to true is debug.
 */
-(void)enableDebug: (BOOL)isDebug;

/**
 *  Set Auth Key for stream
 *
 *  @param authKey Secret key of stream.
 */
-(void)setAuth: (NSString*)authKey;

/**
 *  Set endpoint for sending data
 *
 *  @param endPoint Address of server
 */
-(void)setEndPoint: (NSString*)endPoint;

/**
 *  Send a single event to Atom server.
 *
 *  @param stream     Stream name for saving data in db table
 *  @param data       Data to send
 *  @param callback   Get response data
 */
-(void)putEventWithStream: (NSString*)stream data: (NSString*)data
                 callback: (ISRequestCallback)callback;
-(void)putEventWithStream: (NSString*)stream data: (NSString*)NSData;

/**
 *  Send multiple events (bulk) to Atom server.
 *
 *  @param stream     Stream name for saving data in db table
 *  @param data       bulk of data to send
 *  @param callback   Get response data
 */
-(void)putEventsWithStream: (NSString*)stream arrayData: (NSArray*)data
                  callback: (ISRequestCallback)callback;
-(void)putEventsWithStream: (NSString*)stream arrayData: (NSArray*)data;

/**
 *  Send multiple events (bulk) to Atom server.
 *
 *  @param stream     Stream name for saving data in db table
 *  @param data       bulk of data to send
 *  @param callback   Get response data
 */
-(void)putEventsWithStream: (NSString*)stream stringData: (NSString*)data
                  callback: (ISRequestCallback)callback;
-(void)putEventsWithStream: (NSString*)stream stringData: (NSString*)data;

/**
 *  Health Check
 *
 *  @param callback Response from server
 */
-(void)healthWithCallback: (ISRequestCallback) callback;
-(void)health;

@end
