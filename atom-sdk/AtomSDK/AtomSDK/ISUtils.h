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
 *  Encrypt data with SHA256
 *
 *  @param input Data to encrypt
 *  @param key Encryption key
 *
 *  @return Encrypted string
 */
+(NSString*)encodeHMACWithInput: (NSString*)input key: (NSString*)key;

/**
 *  Convert Object to JSON string
 *
 *  @param data Data to encode
 *
 *  @return JSON String
 */
+(NSString*)objectToJsonStr: (NSObject*)data;

/**
 *  Convert List to JSON String
 *
 *  @param data List to convert
 *
 *  @return JSON String
 */
+(NSString*)listToJsonStr: (NSArray*)data;

/**
 *  Get current time in milliseconds
 *
 *  @return Current time in int64
 */
+(int64_t)currentTimeMillis;

@end
