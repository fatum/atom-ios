//
//  ISDatabaseAdapter.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISSQLiteHandler.h"

#import "ISStreamData.h"
#import "ISBatch.h"

@interface ISDatabaseAdapter : NSObject
{
    BOOL isDebug_;
    
    ISSQLiteHandler* dbHandler_;
}

-(id)init;

-(void)enableDebug: (BOOL)isDebug;

-(void)upgradeWithOldVersion: (int)oldVersion newVersion: (int)newVersion;

-(void)create;

-(int)addEventWithStreamData: (ISStreamData*)streamData data: (NSString*)data;

-(void)addStreamWithStreamData: (ISStreamData*)streamData;

-(ISBatch*)getEventsWithStreamData: (ISStreamData*)streamData limit: (int)limit;

-(ISStreamData*)getStreamWithName: (NSString*)name;

-(NSArray<ISStreamData*>*)getStreams;

-(int)deleteEventsWithStreamData: (ISStreamData*)streamData lastID: (int)lastID;

-(void)deleteStreamWithStreamData: (ISStreamData*)streamData;

-(int)vacuum;

-(int)countWithStreamName: (NSString*)name;
-(int)count;

@end
