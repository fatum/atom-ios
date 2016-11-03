//
//  ISUtils.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/1/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISResponse.h"

typedef void (^ISRequestCallback)(ISResponse*);

@interface ISUtils : NSObject

+(NSString*)encodeHMACWithInput: (NSString*)input key: (NSString*)key;

+(NSString*)objectToJsonStr: (NSObject*)data;

+(NSString*)listToJsonStr: (NSArray*)data;

@end
