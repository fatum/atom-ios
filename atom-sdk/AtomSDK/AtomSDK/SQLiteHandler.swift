//
//  SQLiteHandler.swift
//  AtomSDK
//
//  Created by g8y3e on 6/15/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation
import sqlite3

public class SQLiteHandler {
    let TAG = "SQLiteHandler"
    
    var isDebug_: Bool = false
    var database_: COpaquePointer = nil
    var sqlStatement_: COpaquePointer = nil
    
    public init(name: String, isDebug: Bool) {
        self.isDebug_ = isDebug
        
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(name)
        printLog("DB path: \(fileURL)")
        
        if sqlite3_open(fileURL.path!, &database_) != SQLITE_OK {
            printLog("Error opening database.")
        }
    }
    
    deinit {
        if (database_ != nil) {
            finalizeStatement()
            if sqlite3_close(database_) != SQLITE_OK {
                let errorMsg = String.fromCString(sqlite3_errmsg(database_))
                printLog("Error deinit: \(errorMsg)")
            }
            
            database_ = nil
        }
    }
    
    public func enableDebug(isDebug: Bool) {
        isDebug_ = isDebug
    }
    
    public func prepareSQL(sql: String) -> Bool {
       finalizeStatement()
        
        var returnStatus = true
        if sqlite3_prepare_v2(database_, sql, -1, &sqlStatement_, nil) !=
            SQLITE_OK {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error prepare: \(errorMsg)")
            returnStatus = false
        }
        
        return returnStatus
    }
    
    public func bindInt64(index: Int32, intData: Int64) {
        if (sqlite3_bind_int64(sqlStatement_, index, intData) !=
            SQLITE_OK) {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error bind int64: \(errorMsg)")
        }
    }
    
    public func bindInt32(index: Int32, intData: Int32) {
        if (sqlite3_bind_int(sqlStatement_, index, intData) !=
            SQLITE_OK) {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error bind int64: \(errorMsg)")
        }
    }
    
    public func bindText(index: Int32, strData: String) {
        let data = strData as NSString 
        
        if (sqlite3_bind_text(sqlStatement_, index, data.UTF8String, -1, nil) !=
            SQLITE_OK) {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error bind str: \(errorMsg)")
        }
    }
    
    public func execStatement() -> Bool {
        var returnStatus = true
        
        let status = sqlite3_step(sqlStatement_)
        if  status != SQLITE_DONE {
            let errorMsg = String.fromCString(sqlite3_errmsg(sqlStatement_))
            printLog("Error execute: \(errorMsg)")
            returnStatus = false
        }
        
        return returnStatus
    }
    
    public func execNextStatement() -> Bool {
        var returnStatus = true
        
        let status = sqlite3_step(sqlStatement_)
        if  status != SQLITE_ROW {
            if status != SQLITE_DONE {
                let errorMsg = String.fromCString(sqlite3_errmsg(sqlStatement_))
                printLog("Error execute next: \(errorMsg)")
            }
            returnStatus = false
        }
        
        return returnStatus

    }
    
    public func getColumnInt(index: Int32) -> Int32 {
        return sqlite3_column_int(sqlStatement_, index)
    }
    
    public func getColumnStr(index: Int32) -> String {
        let queryResultCol = sqlite3_column_text(sqlStatement_, index)
        return String.fromCString(UnsafePointer<CChar>(queryResultCol))!
    }
    
    func finalizeStatement() {
        sqlite3_reset(sqlStatement_);
        if (sqlStatement_ != nil) {
            sqlite3_finalize(sqlStatement_)
        }
        
        sqlStatement_ = nil
    }
    
    func printLog(logData: String) {
        if (isDebug_) {
            print(TAG + ": \(logData)")
        }
     }
}