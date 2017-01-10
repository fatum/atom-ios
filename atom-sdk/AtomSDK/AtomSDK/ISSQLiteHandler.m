//
//  ISSQLiteHandler.m
//  AtomSDK
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISSQLiteHandler.h"

@interface ISSQLiteHandler()

-(void)finalizeStatement;

-(NSString*)getSQLError;

-(void)printLog: (NSString*)logData;

@end

@implementation ISSQLiteHandler

-(id)initWithName: (NSString*)name {
    self = [super init];
    
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        
        NSString* documentsDirectory = [paths objectAtIndex:0];
        self->databasePath_= [documentsDirectory
                              stringByAppendingPathComponent:name];
        
        int result = sqlite3_open([self->databasePath_ UTF8String],
                                  &self->database_);
        
        self->isDebug_ = true;
        [self printLog:[NSString stringWithFormat:@"DB path: %@",
                        self->databasePath_]];
        
        if (SQLITE_OK != result) {
            [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                            [self getSQLError]]];
        }
        self->isDebug_ = false;
    }
    return self;
}

-(void)dealloc {
    int result = sqlite3_close(self->database_);
    if (result != SQLITE_OK) {
        
    }
}

-(void)enableDebug: (BOOL)isDebug {
    self->isDebug_ = isDebug;
}

-(unsigned long long)getDBSize {
    unsigned long long fileSize = [[[NSFileManager defaultManager]
                                    attributesOfItemAtPath:self->databasePath_
                                    error:nil] fileSize];
    
    return fileSize;
}

-(BOOL)prepareSQL: (NSString*)sql {
    [self finalizeStatement];
    
    int result = sqlite3_prepare_v2(self->database_, [sql UTF8String], -1,
                                    &self->sqlStatement_, nil);
    
    if (result != SQLITE_OK) {
        [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                        [self getSQLError]]];
        return false;
    }
    return true;
}

-(BOOL)bindInt64WithIndex: (int)index data: (int64_t)data {
    int result = sqlite3_bind_int64(self->sqlStatement_, (int)index, data);
    
    if (result != SQLITE_OK) {
        [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                        [self getSQLError]]];
        return false;
    }
    return true;
}

-(BOOL)bindInt32WithIndex: (int)index data: (int32_t)data {
    int result = sqlite3_bind_int(self->sqlStatement_, (int)index, data);
    
    if (result != SQLITE_OK) {
        [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                        [self getSQLError]]];
        return false;
    }
    return true;
}

-(BOOL)bindTextWithIndex: (int)index data: (NSString*)data {
    int result = sqlite3_bind_text(self->sqlStatement_, (int)index,
                                   [data UTF8String], -1, nil);
    
    if (result != SQLITE_OK) {
        [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                        [self getSQLError]]];
        return false;
    }
    return true;
}

-(BOOL)execStatement {
    int result = sqlite3_step(self->sqlStatement_);
    
    if (result != SQLITE_DONE) {
        [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                        [self getSQLError]]];
        return false;
    }
    return true;
}

-(BOOL)execNextStatement {
    int result = sqlite3_step(self->sqlStatement_);
    
    if (result != SQLITE_ROW) {
        if (result != SQLITE_DONE) {
            [self printLog:[NSString stringWithFormat:@"SQL Error: %@",
                            [self getSQLError]]];
        }
        return false;
    }
    return true;
}

-(int)getColumnCount {
    return sqlite3_column_count(self->sqlStatement_);
}

-(int)getColumnIntWithIndex: (int)index {
    return sqlite3_column_int(self->sqlStatement_, index);
}

-(NSString*)getColumnStrWithIndex: (int)index {
    const char* columnStr = (char *) sqlite3_column_text(self->sqlStatement_,
                                                         index);
    if (columnStr) {
        return [NSString stringWithCString:columnStr
                                  encoding:NSUTF8StringEncoding];
    } else {
        return @"";
    }
}

-(void)finalizeStatement {
    sqlite3_reset(self->sqlStatement_);
    if (self->sqlStatement_ != nil) {
        sqlite3_finalize(self->sqlStatement_);
    }
    
    self->sqlStatement_ = nil;
}

-(NSString*)getSQLError {
    return [NSString stringWithCString:sqlite3_errmsg(self->database_)
                              encoding:NSUTF8StringEncoding];
}

-(void)printLog: (NSString*)logData {
    if (self->isDebug_) {
        NSLog(@"%@: %@",  NSStringFromClass([self class]), logData);
    }
}

@end
