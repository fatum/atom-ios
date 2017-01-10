//
//  ISSQLiteHandler.h
//  AtomSDK
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

/*!
 * @brief SQLite helper class
 */
@interface ISSQLiteHandler : NSObject
{
    BOOL isDebug_;
    sqlite3* database_;
    sqlite3_stmt* sqlStatement_;
    
    NSString* databasePath_;
}

/**
 *  SQL Handler constructor
 *
 *  @param name Database name
 */
-(id)initWithName: (NSString*)name;

/**
 *  SQL Handler destructor
 */
-(void)dealloc;

/**
 *  Enable debug printing
 *
 *  @param isDebug Toggle debug printing
 */
-(void)enableDebug: (BOOL)isDebug;

/**
 *  Get Database size
 *
 *  @return Database size
 */
-(unsigned long long)getDBSize;

/**
 *  Prepare sql string for request
 *
 *  @param sql Request in string format
 *
 *  @return Execute status
 */
-(BOOL)prepareSQL: (NSString*)sql;

/**
 *  Bind Int64 to SQL statement
 *
 *  @param index Request in string format
 *  @param data Data for binding
 */
-(BOOL)bindInt64WithIndex: (int)index data: (int64_t)data;

/**
 *  Bind Int32 to SQL statement
 *
 *  @param index Request in string format
 *  @param data Data for binding
 */
-(BOOL)bindInt32WithIndex: (int)index data: (int32_t)data;

/**
 *  Bind string to SQL statement
 *
 *  @param index Position in binding
 *  @param data Data for binding
 */
-(BOOL)bindTextWithIndex: (int)index data: (NSString*)data;

/**
 *  Execute SQL statement
 *
 *  @return Execute status
 */
-(BOOL)execStatement;

/**
 *  Execute next SQL statement
 *
 *  @return Execute status
 */
-(BOOL)execNextStatement;

/**
 *  Get column count from response
 *
 *  @return Count of column
 */
-(int)getColumnCount;

/**
 *  Get column Int32 value
 *
 *  @param index position of column
 *
 *  @return Int32 column value
 */
-(int)getColumnIntWithIndex: (int)index;

/**
 *  Get column String value
 *
 *  @param index position of column
 *
 *  @return String column value
 */
-(NSString*)getColumnStrWithIndex: (int)index;

@end
