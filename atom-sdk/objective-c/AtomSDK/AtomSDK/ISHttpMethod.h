//
//  ISHttpMethod.h
//  AtomSDKExample
//
//  Created by g8y3e on 10/31/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Types of HTTP methods
 */
typedef enum {
    // Post request with body content
    IS_POST,
    // Get request
    IS_GET
} ISHttpMethod;
