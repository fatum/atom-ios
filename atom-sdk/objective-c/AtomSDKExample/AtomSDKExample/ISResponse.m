//
//  ISResponse.m
//  AtomSDKExample
//
//  Created by g8y3e on 11/1/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISResponse.h"

@implementation ISResponse

@synthesize data = data_;
@synthesize error = error_;
@synthesize status = status_;

-(id)initWithData: (NSString*)data error:(NSString*)error
           status: (long)status {
    self = [super init];
    
    if (self) {
        self->data_ = data;
        self->error_ = error;
        self->status_ = status;
    }
    return self;
}

@end
