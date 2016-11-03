//
//  ISSQLiteHandler.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

@interface ISSQLiteHandler : NSObject
{
    BOOL isDebug_;
    sqlite3* database_;
    sqlite3_stmt* sqlStatement_;
    
    NSString* databasePath_;
}

-(id)initWithName: (NSString*)name;

-(void)dealloc;

-(void)enableDebug: (BOOL)isDebug;

-(unsigned long long)getDBSize;

-(BOOL)prepareSQL: (NSString*)sql;

-(BOOL)bindInt64WithIndex: (int)index data: (int64_t)data;

-(BOOL)bindInt32WithIndex: (int)index data: (int32_t)data;

-(BOOL)bindTextWithIndex: (int) index data: (NSString*)data;

-(BOOL)execStatement;

-(BOOL)execNextStatement;

-(int)getColumnCount;

-(int)getColumnIntWithIndex: (int)index;

-(NSString*)getColumnStrWithIndex: (int)index;

@end
