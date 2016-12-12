//
//  ISBatch.m
//  AtomSDK
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISBatch.h"

@implementation ISBatch

@synthesize events = events_;
@synthesize lastID = lastID_;

-(id)initWithEvents: (NSArray*)events lastID: (int)lastID {
    self = [super init];
    
    if (self) {
        self->events_ = events;
        self->lastID_ = lastID;
    }
    return self;
}

@end
