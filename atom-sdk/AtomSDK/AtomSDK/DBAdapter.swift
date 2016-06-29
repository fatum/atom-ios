//
//  DBAdapter.swift
//  AtomSDK
//
//  Created by g8y3e on 6/15/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/// Adapter class for SQLite Database
public class DBAdapter {
    let TAG = "DBAdapter"
    
    let DATABASE_NAME = "ironsource.atom.sqlite"
    let KEY_STREAM = "stream_name"
    let KEY_DATA = "data"
    let KEY_CREATED_AT = "created_at"
    let KEY_TOKEN = "token"
    
    let STREAMS_TABLE = "streams"
    let REPORTS_TABLE = "reports"
    
    let MAX_DATABASE_SIZE: UInt64 = 1024 * 1024 * 10
    
    var isDebug_: Bool = false
    let dbHandler_: SQLiteHandler
    
    let databaseSemaphore_ = dispatch_semaphore_create(0)
    
    /**
     Database Adatapter constructor
     */
    public init() {
        dbHandler_ = SQLiteHandler(name: DATABASE_NAME)
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
    }
    
    /**
     Enable print debug
     
     - parameter isDebug: Is print debug info in console
     */
    public func enableDebug(isDebug: Bool) {
        isDebug_ = isDebug
        
        dbHandler_.enableDebug(isDebug)
    }
    
    /**
     Upgrade databese
     
     - parameter oldVersion: Previous version od DB
     - parameter newVersion: New version of DB
     */
    public func upgrade(oldVersion: Int, newVersion: Int) {
        if (oldVersion != newVersion) {
            dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
            printLog("Upgrading the IronSource.Atom database");
            dbHandler_.prepareSQL("DROP TABLE IF EXISTS \(STREAMS_TABLE)")
            dbHandler_.execStatement()
            
            dbHandler_.prepareSQL("DROP TABLE IF EXISTS \(REPORTS_TABLE)")
            dbHandler_.execStatement()
            dispatch_semaphore_signal(self.databaseSemaphore_)
            
            create()
        }
    }
    
    /**
     Create tables in Database
     */
    public func create() {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        printLog("Creating IronSource.Atom database.")
        
        let sqlReportsCreate = "CREATE TABLE IF NOT EXISTS \(REPORTS_TABLE)" +
            "(\(REPORTS_TABLE)_id INTEGER PRIMARY KEY AUTOINCREMENT," +
            "\(KEY_DATA) TEXT NOT NULL,\(KEY_STREAM) TEXT NOT NULL," +
            "\(KEY_CREATED_AT) INT NOT NULL);"
        dbHandler_.prepareSQL(sqlReportsCreate)
        dbHandler_.execStatement()
        
        let sqlTablesCreate = "CREATE TABLE IF NOT EXISTS \(STREAMS_TABLE) " +
            "(\(STREAMS_TABLE)_id INTEGER PRIMARY KEY AUTOINCREMENT," +
            "\(KEY_STREAM) TEXT NOT NULL UNIQUE,\(KEY_TOKEN) TEXT NOT NULL);"
        dbHandler_.prepareSQL(sqlTablesCreate)
        dbHandler_.execStatement()
        
        let sqlIndexCreate = "CREATE INDEX IF NOT EXISTS time_idx ON " +
            "\(REPORTS_TABLE) (\(KEY_CREATED_AT));"
        dbHandler_.prepareSQL(sqlIndexCreate)
        dbHandler_.execStatement()
        dispatch_semaphore_signal(self.databaseSemaphore_)
    }
    
    /**
     Adding event to database
     
     - parameter streamData: Data of the stream
     - parameter data:       String data for inserting to DB
     
     - returns: Inserted rows count
     */
    public func addEvent(streamData: StreamData, data: String) -> Int32 {
        printLog("Current DB size: \(dbHandler_.getDBSize())")
        
        if (dbHandler_.getDBSize() > MAX_DATABASE_SIZE) {
            printLog("Make vacuum, current DB size: \(dbHandler_.getDBSize())")
            vacuum()
        }
        
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let sqlInsertReport = "INSERT INTO \(REPORTS_TABLE) (\(KEY_DATA), " +
            "\(KEY_STREAM), \(KEY_CREATED_AT)) VALUES (?, ?, ?);"
        dbHandler_.prepareSQL(sqlInsertReport)
        
        dbHandler_.bindText(1, strData: data)
        dbHandler_.bindText(2, strData: streamData.name)
        dbHandler_.bindInt64(3, intData: CurrentTimeMillis())
        
        dbHandler_.execStatement()
        
        // get report count
        let sqlSelectStreamCount = "SELECT COUNT(*) FROM \(STREAMS_TABLE) " +
            "WHERE \(KEY_STREAM)=?;"
        dbHandler_.prepareSQL(sqlSelectStreamCount)
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.execNextStatement()
        
        let rowsStreamCount = dbHandler_.getColumnInt(0)
        
        let sqlSelectCount = "SELECT COUNT(*) FROM \(REPORTS_TABLE) " +
            "WHERE \(KEY_STREAM)=?;"
        dbHandler_.prepareSQL(sqlSelectCount)
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.execNextStatement()
        
        let rowsCount = dbHandler_.getColumnInt(0)
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        if rowsStreamCount == 0 {
            addStream(streamData)
        }
        
        return rowsCount
    }
    
    /**
     Add stream to Streams table
     
     - parameter streamData: Data of the stream
     */
    public func addStream(streamData: StreamData) {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let sqlInsertToken = "INSERT INTO \(STREAMS_TABLE) (\(KEY_STREAM), " +
            "\(KEY_TOKEN)) VALUES (?, ?);"
        dbHandler_.prepareSQL(sqlInsertToken)
        
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.bindText(2, strData: streamData.token)
        
        dbHandler_.execStatement()
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
    }
    
    /**
     Get events from Database
     
     - parameter streamData: Data of the stream
     - parameter limit:      Max event count
     
     - returns: Batch with event information
     */
    public func getEvents(streamData: StreamData, limit: Int32) -> Batch {
        var eventsList = [String]()
        var lastId: Int32 = -1
        
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let sqlSelectEvents = "SELECT * FROM \(REPORTS_TABLE) " +
            "WHERE \(KEY_STREAM)=? ORDER BY ? ASC LIMIT ?"
        dbHandler_.prepareSQL(sqlSelectEvents)
        
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.bindText(2, strData: KEY_CREATED_AT)
        dbHandler_.bindText(3, strData: "\(limit)")
        
        while (dbHandler_.execNextStatement()) {
            if (dbHandler_.getColumnCount() < 2) {
                break
            }
            
            lastId = dbHandler_.getColumnInt(0)
            eventsList.append(dbHandler_.getColumnStr(1))
        }
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        return Batch(events: eventsList, lastId: lastId)
    }
    
    /**
     Get stream information by name
     
     - parameter streamName: String stream name
     
     - returns: Data of the stream
     */
    public func getStream(streamName: String) -> StreamData {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let streamData = StreamData()
        
        let sqlSelectStreams = "SELECT * FROM \(STREAMS_TABLE) WHERE " +
            "\(KEY_STREAM)=?"
        dbHandler_.prepareSQL(sqlSelectStreams)
        
        dbHandler_.bindText(1, strData: streamName)
        
        while(dbHandler_.execNextStatement()) {
            if (dbHandler_.getColumnCount() < 3) {
                break
            }
            
            streamData.name = dbHandler_.getColumnStr(1)
            streamData.token = dbHandler_.getColumnStr(2)
        }
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        return streamData
    }
    
    /**
     Get all stream information
     
     - returns: List data of streams
     */
    public func getStreams() -> [StreamData] {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        var streamsList = [StreamData]()
        
        let sqlSelectStreams = "SELECT * FROM \(STREAMS_TABLE)"
        dbHandler_.prepareSQL(sqlSelectStreams)
        
        while(dbHandler_.execNextStatement()) {
            if (dbHandler_.getColumnCount() < 3) {
                break
            }
            
            streamsList.append(StreamData(name: dbHandler_.getColumnStr(1),
                token: dbHandler_.getColumnStr(2)))
        }
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        return streamsList
    }
    
    /**
     Deleting events from Database
     
     - parameter streamData: Data of the stream
     - parameter lastId:     Id of last event from DB
     
     - returns: Count of removed elements
     */
    public func deleteEvents(streamData: StreamData, lastId: Int32) -> Int32 {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let sqlDeleteEvents = "DELETE FROM \(REPORTS_TABLE) WHERE " +
            "\(KEY_STREAM) = ? AND \(REPORTS_TABLE)_id <= ?"
        dbHandler_.prepareSQL(sqlDeleteEvents)
        
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.bindInt32(2, intData: lastId)
        
        dbHandler_.execStatement()
        
        let sqlSelectChanges = "SELECT changes() FROM \(REPORTS_TABLE)"
        dbHandler_.prepareSQL(sqlSelectChanges)
        dbHandler_.execNextStatement()
        
        let deletedRows = dbHandler_.getColumnInt(0)
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        return deletedRows
    }
    
    /**
     Delete stream from Streams table
     
     - parameter streamData: Data of the stream
     */
    public func deleteStream(streamData: StreamData) {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let sqlDeleteStreams = "DELETE FROM \(STREAMS_TABLE) WHERE " +
            "\(KEY_STREAM) = ?"
        dbHandler_.prepareSQL(sqlDeleteStreams)
        
        dbHandler_.bindText(1, strData: streamData.name)
        
        dbHandler_.execStatement()
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
    }
    
    /**
     Delete old rows and make Vacuum
     
     - returns: Count of deleted rows
     */
    public func vacuum() -> Int32 {
        let nRows = count()
        
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        let limit: Int32 = Int32(Double(nRows) * 0.3)
        
        let sqlDeleteOld = "DELETE FROM \(REPORTS_TABLE) WHERE " +
            "\(REPORTS_TABLE)_id IN (SELECT \(REPORTS_TABLE)_id " +
            "FROM \(REPORTS_TABLE) ORDER BY \(KEY_CREATED_AT) ASC " +
            "LIMIT \(limit));"
        dbHandler_.prepareSQL(sqlDeleteOld)
        dbHandler_.execStatement()
        
        dbHandler_.prepareSQL("VACUUM")
        dbHandler_.execStatement()
        
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        return limit
    }
    
    /**
     Get count of events from specific stream
     
     - parameter streamName: Data of the stream
     
     - returns: Count of events
     */
    public func count(streamName: String = "") -> Int32 {
        dispatch_semaphore_wait(self.databaseSemaphore_, DISPATCH_TIME_FOREVER)
        var sqlSelectCount = "SELECT COUNT(*) FROM \(REPORTS_TABLE)"
        if streamName != "" {
            sqlSelectCount += " WHERE \(KEY_STREAM) = '\(streamName)'"
        }
        dbHandler_.prepareSQL(sqlSelectCount)
        dbHandler_.execNextStatement()
        
        let rowsCount = dbHandler_.getColumnInt(0)
        dispatch_semaphore_signal(self.databaseSemaphore_)
        
        return rowsCount
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