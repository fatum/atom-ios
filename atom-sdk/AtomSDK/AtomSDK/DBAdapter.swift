//
//  DBAdapter.swift
//  AtomSDK
//
//  Created by g8y3e on 6/15/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

// utils
func CurrentTimeMillis() -> Int64 {
    let nowDouble = NSDate().timeIntervalSince1970
    return Int64(nowDouble * 1000)
}

public class DBAdapter {
    let DATABASE_NAME = "ironsource.atom.sqlite"
    let KEY_STREAM = "stream_name"
    let KEY_DATA = "data"
    let KEY_CREATED_AT = "created_at"
    let KEY_TOKEN = "token"
    
    let STREAMS_TABLE = "streams"
    let REPORTS_TABLE = "reports"
    
    let TAG = "DBAdapter"
    
    var isDebug_: Bool = false
    let dbHandler_: SQLiteHandler
    
    public init(isDebug: Bool) {
        self.isDebug_ = isDebug
        
        dbHandler_ = SQLiteHandler(name: DATABASE_NAME, isDebug: isDebug)
    }
    
    public func enableDebug(isDebug: Bool) {
        isDebug_ = isDebug
        
        dbHandler_.enableDebug(isDebug)
    }
    
    public func upgrade(oldVersion: Int, newVersion: Int) {
        if (oldVersion != newVersion) {
            printLog("Upgrading the IronSource.Atom database");
            dbHandler_.prepareSQL("DROP TABLE IF EXISTS \(STREAMS_TABLE)")
            dbHandler_.execStatement()
            
            dbHandler_.prepareSQL("DROP TABLE IF EXISTS \(REPORTS_TABLE)")
            dbHandler_.execStatement()
            
            create()
        }
    }
    
    public func create() {
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
    }
    
    public func addEvent(streamData: StreamData, data: String) -> Int32 {
        let sqlInsertReport = "INSERT INTO \(REPORTS_TABLE) (\(KEY_DATA), " +
            "\(KEY_STREAM), \(KEY_CREATED_AT)) VALUES (?, ?, ?);"
        dbHandler_.prepareSQL(sqlInsertReport)
        
        dbHandler_.bindText(1, strData: data)
        dbHandler_.bindText(2, strData: streamData.name)
        dbHandler_.bindInt64(3, intData: CurrentTimeMillis())
        
        dbHandler_.execStatement()
        
        // get report count
        let sqlSelectCount = "SELECT COUNT(*) FROM \(REPORTS_TABLE) " +
            "WHERE \(KEY_STREAM)=?;"
        dbHandler_.prepareSQL(sqlSelectCount)
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.execNextStatement()
        
        let rowsCount = dbHandler_.getColumnInt(0)
        if rowsCount == 1 {
            let sqlInsertToken = "INSERT INTO \(STREAMS_TABLE) (\(KEY_STREAM), " +
                "\(KEY_TOKEN)) VALUES (?, ?);"
            dbHandler_.prepareSQL(sqlInsertToken)
            
            dbHandler_.bindText(1, strData: streamData.name)
            dbHandler_.bindText(2, strData: streamData.token)
            
            let status = dbHandler_.execStatement()
            if (!status) {
                
            }
        }
        
        return rowsCount
    }
    
    public func getEvents(streamData: StreamData, limit: Int32) -> Batch {
        var eventsList = [String]()
        var lastId: Int32 = -1
        
        let sqlSelectEvents = "SELECT * FROM \(REPORTS_TABLE) " +
            "WHERE \(KEY_STREAM)=? ORDER BY ? ASC LIMIT ?"
        dbHandler_.prepareSQL(sqlSelectEvents)
        
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.bindText(2, strData: KEY_CREATED_AT)
        dbHandler_.bindText(3, strData: "\(limit)")
        
        
        while (dbHandler_.execNextStatement()) {
            lastId = dbHandler_.getColumnInt(0)
            eventsList.append(dbHandler_.getColumnStr(1))
        }
        
        return Batch(events: eventsList, lastId: lastId)
    }
    
    public func getStreams() -> [StreamData] {
        var streamsList = [StreamData]()
        
        let sqlSelectStreams = "SELECT * FROM \(STREAMS_TABLE)"
        dbHandler_.prepareSQL(sqlSelectStreams)
        
        while(dbHandler_.execNextStatement()) {
            streamsList.append(StreamData(name: dbHandler_.getColumnStr(1),
                token: dbHandler_.getColumnStr(2)))
        }
        
        return streamsList
    }
    
    public func deleteEvents(streamData: StreamData, lastId: Int32) {
        let sqlDeleteEvents = "DELETE FROM \(REPORTS_TABLE) WHERE " +
            "\(KEY_STREAM) = ? AND \(REPORTS_TABLE)_id <= ?"
        dbHandler_.prepareSQL(sqlDeleteEvents)
        
        dbHandler_.bindText(1, strData: streamData.name)
        dbHandler_.bindInt32(2, intData: lastId)
        
        dbHandler_.execStatement()
    }
    
    public func deleteStream(streamData: StreamData) {
        let sqlDeleteStreams = "DELETE FROM \(STREAMS_TABLE) WHERE " +
            "\(KEY_STREAM) = ?"
        dbHandler_.prepareSQL(sqlDeleteStreams)
        
        dbHandler_.bindText(1, strData: streamData.name)
        
        dbHandler_.execStatement()
    }
    
    public func vacuum() {
        let nRows = count()
        let limit: Int32 = Int32(Double(nRows) * 0.3)
        
        let sqlDeleteOld = "DELETE FROM \(REPORTS_TABLE) WHERE " +
            "\(REPORTS_TABLE)_id IN (SELECT \(REPORTS_TABLE)_id " +
            "FROM \(REPORTS_TABLE) ORDER BY \(KEY_CREATED_AT) ASC " +
            "LIMIT \(limit));"
        dbHandler_.prepareSQL(sqlDeleteOld)
        dbHandler_.execStatement()
        
        dbHandler_.prepareSQL("VACUUM")
        dbHandler_.execStatement()
    }
    
    public func count(streamName: String = "") -> Int32 {
        var sqlSelectCount = "SELECT COUNT(*) FROM \(REPORTS_TABLE)"
        if streamName != "" {
            sqlSelectCount += " WHERE \(KEY_STREAM) = '\(streamName)'"
        }
        dbHandler_.prepareSQL(sqlSelectCount)
        dbHandler_.execNextStatement()
        
        return dbHandler_.getColumnInt(0)
    }
    
    func printLog(logData: String) {
        if (isDebug_) {
            print(TAG + ": \(logData)")
        }
    }
}