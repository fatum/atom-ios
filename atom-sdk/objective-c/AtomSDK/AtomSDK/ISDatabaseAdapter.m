//
//  ISDatabaseAdapter.m
//  AtomSDKExample
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISDatabaseAdapter.h"

static NSString* DATABASE = @"ironsource.atom.sqlite";

@implementation ISDatabaseAdapter

-(id)init {
    self = [super init];
    
    if (self) {
        self->dbHandler_ = [[ISSQLiteHandler alloc] initWithName:DATABASE];
    }
    return self;
}

@end
