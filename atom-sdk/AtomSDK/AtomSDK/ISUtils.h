//
//  ISUtils.h
//  AtomSDK
//
//  Created by g8y3e on 11/1/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISResponse.h"

typedef void (^ISRequestCallback)(ISResponse*);

/*!
 * @brief Util methods for Atom SDK
 */
@interface ISUtils : NSObject

/**
 *  Encode data to SHA256
 *
 *  @param input Data to encode
 *  @param key For endcoding data
 *
 *  @return Encoded string
 */
+(NSString*)encodeHMACWithInput: (NSString*)input key: (NSString*)key;

/**
 *  Convert Object to Json string
 *
 *  @param data Data to encode
 *
 *  @return Json string
 */
+(NSString*)objectToJsonStr: (NSObject*)data;

/**
 *  Convert List to Json Str
 *
 *  @param data List of json data str
 *
 *  @return Json string
 */
+(NSString*)listToJsonStr: (NSArray*)data;

/**
 *  Get current milliseconds
 *
 *  @return Current time in int64
 */
+(int64_t)currentTimeMillis;

@end
