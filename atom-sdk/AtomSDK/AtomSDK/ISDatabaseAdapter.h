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
 *  Database Adatapter constructor
 *
 *  @return ISDatabaseAdapter
 */
-(id)init;

/**
 *  Database Adatapter constructor
 *
 *  @param isDebug Is print debug info in console
 */
-(void)enableDebug: (BOOL)isDebug;

/**
 *  Upgrade databese
 *
 *  @param oldVersion Previous version od DB
 *  @param newVersion New version of DB
 */
-(void)upgradeWithOldVersion: (int)oldVersion newVersion: (int)newVersion;

/**
 * Create tables in Database
 */
-(void)create;

/**
 *  Upgrade databese
 *
 *  @param streamData Previous version od DB
 *  @param data String data for inserting to DB
 *
 *  @return Inserted rows count
 */
-(int)addEventWithStreamData: (ISStreamData*)streamData data: (NSString*)data;

/**
 *  Add stream to Streams table
 *
 *  @param streamData Data of the stream
 */
-(void)addStreamWithStreamData: (ISStreamData*)streamData;

/**
 *  Add stream to Streams table
 *
 *  @param streamData Data of the stream
 *  @param limit Max event count
 *
 *  @return Batch with event information
 */
-(ISBatch*)getEventsWithStreamData: (ISStreamData*)streamData limit: (int)limit;

/**
 *  Get stream information by name
 *
 *  @param name String stream name
 *
 *  @return Data of the stream
 */
-(ISStreamData*)getStreamWithName: (NSString*)name;

/**
 *  Get all stream information
 *
 *  @return List data of streams
 */
-(NSArray<ISStreamData*>*)getStreams;

/**
 *  Deleting events from Database
 *
 *  @param streamData Data of the stream
 *  @param lastID Id of last event from DB
 *
 *  @return Count of removed elements
 */
-(int)deleteEventsWithStreamData: (ISStreamData*)streamData lastID: (int)lastID;

/**
 *  Delete stream from Streams table
 *
 *  @param streamData String stream name
 */
-(void)deleteStreamWithStreamData: (ISStreamData*)streamData;

/**
 *  Delete old rows and make Vacuum
 *
 *  @return Count of deleted rows
 */
-(int)vacuum;

/**
 *  Get count of events from specific stream
 *
 *  @param name Data of the stream
 *
 *  @return Count of events
 */
-(int)countWithStreamName: (NSString*)name;
-(int)count;

@end
