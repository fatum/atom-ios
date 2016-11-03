//
//  ISDatabaseAdapter.m
//  AtomSDKExample
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISDatabaseAdapter.h"

#import "ISUtils.h"

static NSString* DATABASE = @"ironsource.atom.sqlite";
static NSString* KEY_STREAM = @"stream_name";
static NSString* KEY_DATA = @"data";
static NSString* KEY_CREATED_AT = @"created_at";
static NSString* KEY_TOKEN = @"token";

static NSString* STREAMS_TABLE = @"streams";
static NSString* REPORTS_TABLE = @"reports";

static int MAX_DATABASE_SIZE = 1024 * 1024 * 10;

@interface ISDatabaseAdapter()

{
    dispatch_semaphore_t databaseSemaphore_;
}

-(void)printLog: (NSString*)logData;

@end

@implementation ISDatabaseAdapter

-(id)init {
    self = [super init];
    
    if (self) {
        self->databaseSemaphore_ = dispatch_semaphore_create(0);
        
        self->dbHandler_ = [[ISSQLiteHandler alloc] initWithName:DATABASE];
        
        dispatch_semaphore_signal(self->databaseSemaphore_);
    }
    return self;
}

-(void)enableDebug: (BOOL)isDebug {
    self->isDebug_ = isDebug;
}

-(void)upgradeWithOldVersion: (int)oldVersion newVersion: (int)newVersion {
    if (oldVersion != newVersion) {
        dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
        [self printLog:@"Upgrading the IronSource.Atom database."];
        [self->dbHandler_ prepareSQL:[NSString stringWithFormat:
                                     @"DROP TABLE IF EXISTS %@",
                                     STREAMS_TABLE]];
        [self->dbHandler_ execStatement];
        
        [self->dbHandler_ prepareSQL:[NSString stringWithFormat:
                                      @"DROP TABLE IF EXISTS %@",
                                      REPORTS_TABLE]];
        [self->dbHandler_ execStatement];
        dispatch_semaphore_signal(self->databaseSemaphore_);
        
        [self create];
    }
}

-(void)craete {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    
    [self printLog:@"Creating IronSource.Atom database!"];
    
    NSString* sqlReportsCreate = [NSString stringWithFormat:
                                  @"CREATE TABLE IF NOT EXIST %@" \
                                  @"(%@_id INTEGER PRIMARY KEY AUTOINCREMENT, " \
                                  @"%@ TEXT NOT NULL, %@ TEXT NOT NULL, " \
                                  @"%@ INT NOT NULL);", REPORTS_TABLE,
                                  REPORTS_TABLE, KEY_DATA, KEY_STREAM,
                                  KEY_CREATED_AT];
    [self->dbHandler_ prepareSQL:sqlReportsCreate];
    [self->dbHandler_ execStatement];
    
    NSString* sqlTablesCreate = [NSString stringWithFormat:
                                 @"CREATE TABLE IF NOT EXISTS %@ " \
                                 @"(%@ _id INTEGER PRIMARY KEY AUTOINCREMENT, " \
                                 @"%@ TEXT NOT NULL UNIQUE, %@ TEXT NOT NULL);",
                                 STREAMS_TABLE, STREAMS_TABLE, KEY_STREAM,
                                 KEY_TOKEN];
    [self->dbHandler_ prepareSQL:sqlTablesCreate];
    [self->dbHandler_ execStatement];

    NSString* sqlIndexCreate = [NSString stringWithFormat:
                                @"CREATE INDEX IF NOT EXISTS time_idx ON " \
                                @"%@ (%@);", REPORTS_TABLE, KEY_CREATED_AT];
    [self->dbHandler_ prepareSQL:sqlIndexCreate];
    [self->dbHandler_ execStatement];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
}

-(int)addEventWithStreamData: (ISStreamData*)streamData data: (NSString*)data {
    [self printLog:[NSString stringWithFormat:@"Current DB size: %llu",
                    [self->dbHandler_ getDBSize]]];
    
    if ([self->dbHandler_ getDBSize] > MAX_DATABASE_SIZE) {
        [self printLog:@"Make vacuum!"];
        [self vacuum];
    }
    
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    NSString* sqlInsertReport = [NSString stringWithFormat:
                                 @"INSERT INTO %@ (%@, %@, %@) VALUES (?, ?, ?);",
                                 REPORTS_TABLE, KEY_DATA, KEY_STREAM,
                                 KEY_CREATED_AT];
    [self->dbHandler_ prepareSQL:sqlInsertReport];
    
    [self->dbHandler_ bindTextWithIndex:1 data:data];
    [self->dbHandler_ bindTextWithIndex:2 data:[streamData name]];
    [self->dbHandler_ bindInt64WithIndex:3 data:[ISUtils currentTimeMillis]];
    
    [self->dbHandler_ execStatement];
    
    NSString* sqlSelectStreamCount = [NSString stringWithFormat:
                                      @"SELECT COUNT(*) FROM %@ WHERE %@ = ?;",
                                      STREAMS_TABLE, KEY_STREAM];
    
    [self->dbHandler_ prepareSQL:sqlSelectStreamCount];
    [self->dbHandler_ bindTextWithIndex:1 data:[streamData name]];
    
    [self->dbHandler_ execNextStatement];
    
    
    int rowsStreamCount = [self->dbHandler_ getColumnIntWithIndex:0];
    
    NSString* sqlSelectCount = [NSString stringWithFormat:
                                @"SELECT COUNT(*) FROM %@ WHERE %@ = ?;",
                                REPORTS_TABLE, KEY_STREAM];
    [self->dbHandler_ prepareSQL:sqlSelectCount];
    [self->dbHandler_ bindTextWithIndex:1 data:[streamData name]];
    
    [self->dbHandler_ execNextStatement];
    
    int rowsCount = [self->dbHandler_ getColumnIntWithIndex:0];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    if (rowsStreamCount == 0) {
        [self addStreamWithStreamData:streamData];
    }
    
    return rowsCount;
}

-(void)addStreamWithStreamData: (ISStreamData*)streamData {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    
    NSString* sqlInsertToken = [NSString stringWithFormat:
                                @"INSERT INTO %@ (%@, %@) VALUES (?, ?);",
                                STREAMS_TABLE, KEY_STREAM, KEY_TOKEN];
    [self->dbHandler_ prepareSQL:sqlInsertToken];
    
    [self->dbHandler_ bindTextWithIndex:1 data:[streamData name]];
    [self->dbHandler_ bindTextWithIndex:2 data:[streamData token]];
    
    [self->dbHandler_ execStatement];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
}

-(ISBatch*)getEventsWithStreamData: (ISStreamData*)streamData limit: (int)limit {
    NSMutableArray<NSString*>* eventsList = [[NSMutableArray alloc] init];
    int lastID = -1;
    
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    NSString* sqlSelectEvents = [NSString stringWithFormat:
                                 @"SELECT * FROM %@ WHERE %@ = ? ORDER BY ?" \
                                 @" ASC LIMIT ?", REPORTS_TABLE, KEY_STREAM];
    
    [self->dbHandler_ prepareSQL:sqlSelectEvents];
    
    [self->dbHandler_ bindTextWithIndex:1 data:[streamData name]];
    [self->dbHandler_ bindTextWithIndex:2 data:KEY_CREATED_AT];
    [self->dbHandler_ bindTextWithIndex:3 data:[NSString stringWithFormat:@"%d",
                                               limit]];
    
    while ([self->dbHandler_ execNextStatement]) {
        if ([self->dbHandler_ getColumnCount] < 2) {
            break;
        }
        
        lastID = [self->dbHandler_ getColumnIntWithIndex:0];
        [eventsList addObject:[self->dbHandler_ getColumnStrWithIndex:1]];
    }
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    return [[ISBatch alloc] initWithEvents:eventsList lastID:lastID];
}

-(ISStreamData*)getStreamWithName: (NSString*)name {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    ISStreamData* streamData = [[ISStreamData alloc] initWithName:@""
                                                            token:@""];
    
    NSString* sqlSelectStream = [NSString stringWithFormat:
                                 @"SELECT * FROM %@ WHERE %@ = ?",
                                 STREAMS_TABLE, KEY_STREAM];
    
    [self->dbHandler_ prepareSQL:sqlSelectStream];
    [self->dbHandler_ bindTextWithIndex:1 data:name];
    
    while([self->dbHandler_ execNextStatement]) {
        if ([self->dbHandler_ getColumnCount] < 3) {
            break;
        }
        
        [streamData setName:[self->dbHandler_ getColumnStrWithIndex:1]];
        [streamData setToken:[self->dbHandler_ getColumnStrWithIndex:2]];
    }
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    return streamData;
}

-(NSArray<ISStreamData*>*)getStreams {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    NSMutableArray<ISStreamData*>* streamList = [[NSMutableArray alloc] init];
    
    NSString* sqlSelectStreams = [NSString stringWithFormat:
                                  @"SELECT * FROM %@", STREAMS_TABLE];
    
    [self->dbHandler_ prepareSQL:sqlSelectStreams];
    
    while ([self->dbHandler_ execNextStatement]) {
        if ([self->dbHandler_ getColumnCount] < 3) {
            break;
        }
        
        NSString* name = [self->dbHandler_ getColumnStrWithIndex:1];
        NSString* token = [self->dbHandler_ getColumnStrWithIndex:2];
        
        [streamList addObject:[[ISStreamData alloc] initWithName:name
                                                           token:token]];
    }
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    return streamList;
}

-(int)deleteEventsWithStreamData: (ISStreamData*)streamData lastID: (int)lastID {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    NSString* sqlDeleteEvents = [NSString stringWithFormat:
                                 @"DELETE FROM %@ WHERE %@ = ? AND %@_id <= ?",
                                 REPORTS_TABLE, KEY_STREAM, REPORTS_TABLE];
    
    [self->dbHandler_ prepareSQL:sqlDeleteEvents];
    [self->dbHandler_ bindTextWithIndex:1 data:[streamData name]];
    [self->dbHandler_ bindInt32WithIndex:2 data:lastID];
    
    [self->dbHandler_ execStatement];
    
    NSString* sqlSelectChanges = [NSString stringWithFormat:
                                  @"SELECT changes() FROM %@",
                                  REPORTS_TABLE];
    
    [self->dbHandler_ prepareSQL:sqlSelectChanges];
    [self->dbHandler_ execNextStatement];
    
    int deletedRows = [self->dbHandler_ getColumnIntWithIndex:0];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    return deletedRows;
}

-(void)deleteStreamWithStreamData: (ISStreamData*)streamData {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    NSString* sqlDeleteStream = [NSString stringWithFormat:
                                 @"DELETE FROM %@ WHERE %@ = ?",
                                 STREAMS_TABLE, KEY_STREAM];
    
    [self->dbHandler_ prepareSQL:sqlDeleteStream];
    [self->dbHandler_ bindTextWithIndex:1 data:[streamData name]];
    [self->dbHandler_ execStatement];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
}

-(int)vacuum {
    int nRows = [self count];
    
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    int limit = (int)(((double)nRows) * 0.3);
    
    NSString* sqlDeleteOld = [NSString stringWithFormat:
                              @"DELETE FROM %@ WHERE %@_id IN (SELECT %@_id " \
                              @"FROM %@ ORDER BY %@ ASC LIMIT %d));",
                              REPORTS_TABLE, REPORTS_TABLE, REPORTS_TABLE,
                              REPORTS_TABLE, KEY_CREATED_AT, limit];
    [self->dbHandler_ prepareSQL:sqlDeleteOld];
    [self->dbHandler_ execStatement];
    
    [self->dbHandler_ prepareSQL:@"VACUUM"];
    [self->dbHandler_ execStatement];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    return limit;
}

-(int)countWithStreamName: (NSString*)name {
    dispatch_semaphore_wait(self->databaseSemaphore_, DISPATCH_TIME_FOREVER);
    NSString* sqlSelectCount = [NSString stringWithFormat:
                                @"SELECT COUNT(*) FROM %@", REPORTS_TABLE];

    if ([name length] > 0) {
        sqlSelectCount = [NSString stringWithFormat:@"%@ WHERE %@ = '%@'",
                          sqlSelectCount, KEY_STREAM, name];
    }
    
    [self->dbHandler_ prepareSQL:sqlSelectCount];
    [self->dbHandler_ execNextStatement];
    
    int rowsCount = [self->dbHandler_ getColumnIntWithIndex:0];
    
    dispatch_semaphore_signal(self->databaseSemaphore_);
    
    return rowsCount;
}

-(int)count {
    return [self countWithStreamName:@""];
}

@end
