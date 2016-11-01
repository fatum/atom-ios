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
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [input cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData* result = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
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
@end
