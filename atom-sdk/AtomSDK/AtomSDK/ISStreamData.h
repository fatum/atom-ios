//
//  ISStreamData.h
//  AtomSDKExample
//
//  Created by Valentine.Pavchuk on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISStreamData : NSObject
{
    NSString* name_;
    NSString* token_;
}

@property NSString* name;
@property NSString* token;

-(id)initWithName: (NSString*)name token: (NSString*)token;
-(id)init;

@end
