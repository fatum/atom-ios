//
//  ISAtomTracker.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/3/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISAtomTracker : NSObject

-(id)init;

-(void)trackWithStream: (NSString*)stream data: (NSString*)data
                 token: (NSString*)token;

-(void)flushWithStream: (NSString*)stream;
-(void)flush;

@end
