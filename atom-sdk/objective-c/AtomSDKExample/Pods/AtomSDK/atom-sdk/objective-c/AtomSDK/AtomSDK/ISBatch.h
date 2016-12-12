//
//  ISBatch.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISBatch : NSObject
{
    NSArray* events_;
    int lastID_;
}

@property NSArray* events;
@property int lastID;

-(id)initWithEvents: (NSArray*)events lastID: (int)lastID;

@end
