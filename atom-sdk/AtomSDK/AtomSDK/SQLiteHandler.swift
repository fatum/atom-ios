//
//  SQLiteHandler.swift
//  AtomSDK
//
//  Created by g8y3e on 6/15/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation
import sqlite3

/// SQL helper class
public class SQLiteHandler {
    let TAG = "SQLiteHandler"
    
    var isDebug_: Bool = false
    var database_: COpaquePointer = nil
    var sqlStatement_: COpaquePointer = nil
        
    /**
     SQL Handler contructor
     
     - parameter name:    database name
     - parameter isDebug: is print debug in console
     */
    public init(name: String) {
        self.isDebug_ = true
        
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(name)
        printLog("DB path: \(fileURL)")
        
        if sqlite3_open(fileURL.path!, &database_) != SQLITE_OK {
            printLog("Error opening database.")
        }
        
        self.isDebug_ = false
    }
    
    /**
     SQL Handler destructor
     */
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
    
    /**
     Enable print logs
     
     - parameter isDebug: Is print log to console
     */
    public func enableDebug(isDebug: Bool) {
        isDebug_ = isDebug
    }
    
    /**
     Prepare sql string for request
     
     - parameter sql: Request in string
     
     - returns: Execute status
     */
    public func prepareSQL(sql: String) -> Bool {
        objc_sync_enter(self)
            finalizeStatement()
        objc_sync_exit(self)
        
        var returnStatus = true
        if sqlite3_prepare_v2(database_, sql, -1, &sqlStatement_, nil) !=
            SQLITE_OK {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error prepare: \(errorMsg)")
            returnStatus = false
        }
        
        return returnStatus
    }
    
    /**
     Bind Int64 to SQL statement
     
     - parameter index:   Position in binding
     - parameter intData: Data for binding
     */
    public func bindInt64(index: Int32, intData: Int64) {
        if (sqlite3_bind_int64(sqlStatement_, index, intData) !=
            SQLITE_OK) {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error bind int64: \(errorMsg)")
        }
    }
    
    /**
     Bind Int32 to SQL statement
     
     - parameter index:   Position in binding
     - parameter intData: Data for binding
     */
    public func bindInt32(index: Int32, intData: Int32) {
        if (sqlite3_bind_int(sqlStatement_, index, intData) !=
            SQLITE_OK) {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error bind int64: \(errorMsg)")
        }
    }
    
    /**
     Bind string to SQL statement
     
     - parameter index:   Position in binding
     - parameter strData: Data for binding
     */
    public func bindText(index: Int32, strData: String) {
        let data = strData as NSString 
        
        if (sqlite3_bind_text(sqlStatement_, index, data.UTF8String, -1, nil) !=
            SQLITE_OK) {
            let errorMsg = String.fromCString(sqlite3_errmsg(database_))
            printLog("Error bind str: \(errorMsg)")
        }
    }
    
    /**
     Execute SQL statement
     
     - returns: Execute status
     */
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
    
    /**
     Execute next SQL statement
     
     - returns: Execute status
     */
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
    
    /**
     Get column count from response
     
     - returns: Count of column
     */
    public func getColumnCount() -> Int32 {
        return sqlite3_column_count(sqlStatement_)
    }
    
    /**
     Get column Int32 value
     
     - parameter index: position of column
     
     - returns: Int32 column value
     */
    public func getColumnInt(index: Int32) -> Int32 {
        return sqlite3_column_int(sqlStatement_, index)
    }
    
    /**
     Get column String value
     
     - parameter index: position of column
     
     - returns: String column value
     */
    public func getColumnStr(index: Int32) -> String {
        let queryResultCol = sqlite3_column_text(sqlStatement_, index)
        return String.fromCString(UnsafePointer<CChar>(queryResultCol))!
    }
    
    /**
     Finilize SQL statement
     */
    func finalizeStatement() {
        sqlite3_reset(sqlStatement_);
        if (sqlStatement_ != nil) {
            sqlite3_finalize(sqlStatement_)
        }
        
        sqlStatement_ = nil
    }
    
    /**
     Prints the log.
     
     - parameter logData: Log data.
     */
    func printLog(logData: String) {
        if (isDebug_) {
            print(TAG + ": \(logData)\n")
        }
     }
}