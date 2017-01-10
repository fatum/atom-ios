//
//  ISUtils.m
//  AtomSDKExample
//
//  Created by g8y3e on 11/1/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISUtils.h"

#include <CommonCrypto/CommonCrypto.h>

@implementation ISUtils
+(NSString*)encodeHMACWithInput: (NSString*)input key: (NSString*)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [input cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac (kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSMutableString *output = [NSMutableString stringWithCapacity:
                               (CC_SHA256_DIGEST_LENGTH * 2)];
    
    for (int index = 0; index < CC_SHA256_DIGEST_LENGTH; index++) {
        [output appendFormat:@"%02x", cHMAC[index]];
    }
    
    return output;
}

+(NSString*)objectToJsonStr: (NSObject*)data {
    NSError* jsonError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0
                                                         error:&jsonError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(NSString*)listToJsonStr: (NSArray*)data {
    return [NSString stringWithFormat:@"[%@]",
            [data componentsJoinedByString:@","]];
}

+(int64_t)currentTimeMillis {
    return (int64_t)([[NSDate date] timeIntervalSince1970] * 1000.0);
}
@end
