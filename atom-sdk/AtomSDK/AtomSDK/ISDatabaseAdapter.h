//
//  ISDatabaseAdapter.h
//  AtomSDK
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISSQLiteHandler.h"

#import "ISStreamData.h"
#import "ISBatch.h"

/*!
 * @brief Adapter class for SQLite Database
 */
@interface ISDatabaseAdapter : NSObject
{
    BOOL isDebug_;
    
    ISSQLiteHandler* dbHandler_;
}

/**
 *  Database Adapter constructor
 *
 *  @return ISDatabaseAdapter
 */
-(id)init;

/**
 *  Database Adapter constructor
 *
 *  @param isDebug Enable debug printing
 */
-(void)enableDebug: (BOOL)isDebug;

/**
 *  Upgrade database
 *
 *  @param oldVersion Previous version of DB
 *  @param newVersion New version of DB
 */
-(void)upgradeWithOldVersion: (int)oldVersion newVersion: (int)newVersion;

/**
 * Create tables in Database
 */
-(void)create;

/**
 *  Add event to DB
 *
 *  @param streamData Atom Stream object
 *  @param data String with data to be inserted
 *
 *  @return Inserted rows count
 */
-(int)addEventWithStreamData: (ISStreamData*)streamData data: (NSString*)data;

/**
 *  Add stream to Streams table
 *
 *  @param streamData Atom Stream object
 */
-(void)addStreamWithStreamData: (ISStreamData*)streamData;

/**
 *  Get events based on Stream data
 *
 *  @param streamData Atom Stream object
 *  @param limit max events to get
 *
 *  @return Batch of events
 */
-(ISBatch*)getEventsWithStreamData: (ISStreamData*)streamData limit: (int)limit;

/**
 *  Get stream information by name
 *
 *  @param name Atom Stream name
 *
 *  @return StreamData related to the given stream
 */
-(ISStreamData*)getStreamWithName: (NSString*)name;

/**
 *  Get all streams information
 *
 *  @return List with streams data.
 */
-(NSArray<ISStreamData*>*)getStreams;

/**
 *  Deleting events from Database
 *
 *  @param streamData Atom Stream object
 *  @param lastID ID of last event in DB
 *
 *  @return Number of removed elements
 */
-(int)deleteEventsWithStreamData: (ISStreamData*)streamData lastID: (int)lastID;

/**
 *  Delete stream from Streams table
 *
 *  @param streamData Atom Stream object
 */
-(void)deleteStreamWithStreamData: (ISStreamData*)streamData;

/**
 *  Delete old rows and do Vacuum
 *
 *  @return Number of deleted rows
 */
-(int)vacuum;

/**
 *  Return count of events for a specific Atom Stream
 *
 *  @param name Atom Stream name
 *
 *  @return Number of events for the given Stream
 */
-(int)countWithStreamName: (NSString*)name;
-(int)count;

@end
