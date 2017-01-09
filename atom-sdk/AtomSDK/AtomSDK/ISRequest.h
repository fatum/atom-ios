//
//  ISRequest.h
//  AtomSDK
//
//  Created by g8y3e on 11/1/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISResponse.h"

#import "ISUtils.h"

/*!
 * @brief Wrapper to basic http for sending HTTP requests to server
 */
@interface ISRequest : NSObject <NSURLSessionDelegate>
{
    NSString* url_;
    NSString* data_;
    
    BOOL isDebug_;
    
    NSMutableDictionary<NSString*, NSString*>* headers_;
    
    ISRequestCallback callback_;
}

/**
 *  Constructor for Request
 *
 *  @param url      Atom API address
 *  @param data     Data to send
 *  @param headers  Headers to send
 *  @param callback Call with response data
 *  @param isDebug  For printing debug info.
 *
 *  @return ISRequest
 */
-(id)initWithUrl: (NSString*)url data: (NSString*)data
         headers: (NSMutableDictionary<NSString*, NSString*>*) headers
        callback: (ISRequestCallback)callback
         isDebug: (BOOL)isDebug;

/**
 *  Constructor for Request
 *
 *  @param url      Atom API address
 *  @param data     Data to send
 *  @param headers  Headers to send
 *  @param isDebug  For printing debug info.
 *
 *  @return ISRequest
 */
-(id)initWithUrl:(NSString *)url data:(NSString *)data
         headers:(NSMutableDictionary<NSString *,NSString *> *)headers
         isDebug:(BOOL)isDebug;
/**
 *  HTTP GET request to server
 */
-(void)get;

/**
 *  HTTP POST request to server
 */
-(void)post;

@end
