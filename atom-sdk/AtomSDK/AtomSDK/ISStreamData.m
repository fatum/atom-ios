//
//  ISStreamData.m
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISStreamData.h"

@implementation ISStreamData

@synthesize name = name_;
@synthesize token = token_;

-(id)initWithName: (NSString*)name token: (NSString*)token {
    self = [super init];
    
    if (self) {
        self->name_ = name;
        self->token_ = token;
    }
    return self;
}

-(id)init {
    return [self initWithName:@"" token:@""];
}

@end
