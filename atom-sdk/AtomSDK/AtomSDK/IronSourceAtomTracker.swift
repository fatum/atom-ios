//
//  IronSourceAtomTracker.swift
//  AtomSDK
//
//  Created by g8y3e on 6/10/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/// API Tracker class - for flush data in intervals
public class IronSourceAtomTracker {
    let TAG = "IronSourceAtomTracker"
    
    var flushInterval_: Double = 10
    var bulkSize_: Int32 = 1000
    var bulkBytesSize_: Int32 = 64 * 1024
    
    var timer_:NSTimer?
    
    var api_: IronSourceAtom
    
    var isDebug_: Bool = false
    var isFirst_: Bool = true
    var isRunTimeFlush_: Bool = true
    
    var flushSizedLock = 1
    var flushLock = 1
    var isFlushSizedRunned: Bool = false
    var isFlushRunned: Dictionary<String, Bool>
    
    var database_: DBAdapter
    
    let semaphore_ = dispatch_semaphore_create(0)
    
    /**
     API Tracker constructor
     */
    public init() {
        self.api_ = IronSourceAtom()
        database_ = DBAdapter()
        database_.create()
        
        isFlushRunned = Dictionary<String, Bool>()
        
       // initTimerFlush()
        self.dispatchSemapthore()
    }
    
    /**
     API Tracker destructor
     */
    deinit {
        self.invalidateTimerFlush()
    }
    
    /**
     Remove timer for flush task
     */
    func invalidateTimerFlush() {
        self.timer_?.invalidate()
        self.timer_ = nil
    }
    
    /**
     Init timer for flush data
     */
    func initTimerFlush() {
        self.invalidateTimerFlush()
        
        self.printLog("Create flush timer with intervals: \(self.flushInterval_)!")
        self.timer_ = NSTimer
            .scheduledTimerWithTimeInterval(self.flushInterval_,
                                            target: self,
                                            selector: #selector(IronSourceAtomTracker.timerFlush),
                                            userInfo: nil, repeats: true)
    }
    
    /**
     Enabling print debug information
     
     - parameter isDebug: If set to true is debug.
     */
    public func enableDebug(isDebug: Bool) {
        self.isDebug_ = isDebug
        
        self.api_.enableDebug(isDebug)
        self.database_.enableDebug(isDebug)
    }
    
    /**
     Set Auth Key for stream
     
     - parameter authKey: Secret key of stream
     */
    public func setAuth(authKey: String) {
        self.api_.setAuth(authKey)
    }
    
    /**
     Set endpoint for send data
     
     - parameter endpoint: Address of the server
     */
    public func setEndpoint(endpoint: String) {
        self.api_.setEndpoint(endpoint)
    }
    
    /**
     Set Bulk data count
     
     - parameter bulkSize: Count of event for flush
     */
    public func setBulkSize(bulkSize: Int32) {
        self.bulkSize_ = bulkSize
    }
    
    /**
     Set Bult data bytes size
     
     - parameter bulkBytesSize: Size in bytes
     */
    public func setBulkBytesSize(bulkBytesSize: Int32) {
        self.bulkBytesSize_ = bulkBytesSize
    }
    
    /**
     Set intervals for flushing data
     
     - parameter flushInterval: Intervals in seconds
     */
    public func setFlushInterval(flushInterval: Double) {
        self.flushInterval_ = flushInterval
    }
    
    /**
     Track data to server
     
     - parameter stream: Name of the stream
     - parameter data:   Info for sending
     */
    public func track(stream: String, data: String, token: String = "") {
        var tokenStr = token
        if (tokenStr == "") {
            tokenStr = self.api_.authKey_
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            let rowsCount = self.database_.addEvent(StreamData(name: stream, token: tokenStr),
                                                    data: data)
            
            if (rowsCount >= self.bulkSize_) {
                self.flushAsync(stream, checkSize: true)
            }
        }
    }
    
    /**
     Wrapper for flush method in timer
     */
    @objc func timerFlush() {
        self.printLog("Flush from timer.")
        if (self.isRunTimeFlush_) {
            self.flush()
        }
    }
    
    /**
     Send data to atom server
     
     - parameter streamData:   Stream data: name, token
     - parameter data:     Info for sending
     - parameter dataSize: Size of info's
     - parameter method:   Http method (POST or GET)
     - parameter callback: callback for retry
     */
    func sendData(streamData: StreamData, data: String, dataSize: Int = 1,
                  method: HttpMethod = HttpMethod.POST, callback: AtomCallback?) {
        self.api_.setAuth(streamData.token)
        if (dataSize == 1) {
            self.api_.putEvent(streamData.name, data: data, method: method,
                               callback: callback)
        } else if (dataSize > 1) {
            self.api_.putEvents(streamData.name, data: data, callback: callback)
        }
    }
    
    /**
     Flush batch data object
     
     - parameter streamData: Name of stream to flush
     - parameter batch:      Data object
     */
    func flushData(streamData: StreamData, batch: Batch) {
        let batchDataStr:String
        if (batch.events.count == 1) {
            batchDataStr = batch.events[0]
        } else {
            batchDataStr = ListToJsonStr(batch.events)
        }
        
        let batchSize: Int = batch.events.count
        
        var callback: AtomCallback?
        var timeout:Double = 1
        
        callback = {response -> Void in
            var isOk = false
            if (response.error != "") {
                if (response.status >= 500 || response.status < 0) {
                    self.isRunTimeFlush_ = false
                    dispatch_sync(dispatch_get_main_queue()) {
                        let fireDate = timeout + CFAbsoluteTimeGetCurrent()
                        if (timeout < 10 * 60) {
                            timeout = timeout * 2
                            let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0,   0, 0) { _ in
                                self.sendData(streamData, data: batchDataStr, dataSize: batchSize,
                                              method: HttpMethod.POST, callback: callback)
                            }
                            CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
                        } else {
                            self.isRunTimeFlush_ = true
                            self.dispatchSemapthore()
                            self.printLog("Server not response more then 10min.")
                        }
                    }
                } else {
                    self.printLog("Server error: \(response.error)")
                    isOk = true
                }
            } else {
                self.printLog("Server response: \(response.data)")
                isOk = true
            }
            
            if (isOk) {
                self.isRunTimeFlush_ = true
                self.database_.deleteEvents(streamData,
                                            lastId: batch.lastId)
                
                if (self.database_.count(streamData.name) == 0) {
                    self.database_.deleteStream(streamData)
                }
                
                dispatch_sync(dispatch_get_main_queue()) {
                    self.initTimerFlush()
                }
                
                self.dispatchSemapthore()
            }
        }
        
        sendData(streamData, data: batchDataStr, dataSize: batchSize,
                 method: HttpMethod.POST, callback: callback)
    }
    
    /**
     Flush data async
     
     - parameter streamName: Name of the stream
     - parameter checkSize:  If check size events
     */
    func flushAsync(streamName: String, checkSize: Bool = false) {
        // check if flush runned
        if (checkSize) {
            objc_sync_enter(flushSizedLock)
            if (isFlushSizedRunned) {
                printLog("Flush sized runned")
                objc_sync_exit(flushSizedLock)
                return
            }
            
            isFlushSizedRunned = true
            objc_sync_exit(flushSizedLock)
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)){
            self.printLog("Dispatch start")
            dispatch_semaphore_wait(self.semaphore_, DISPATCH_TIME_FOREVER)
            NSThread.sleepForTimeInterval(0.2)
            self.printLog("Dispatch end")
            
            if (checkSize) {
                objc_sync_enter(self.flushSizedLock)
                self.isFlushSizedRunned = false
                objc_sync_exit(self.flushSizedLock)
                
                let eventCount = self.database_.count(streamName)
                if (eventCount < self.bulkSize_) {
                    self.dispatchSemapthore()
                    return
                }
            } else {
                objc_sync_enter(self.flushLock)
                self.isFlushRunned[streamName] = false
                objc_sync_exit(self.flushLock)
            }
            
            if (streamName.characters.count > 0) {
                var batch: Batch?
                var bulkSize = self.bulkSize_
                let streamData = self.database_.getStream(streamName)
                
                while (true) {
                    batch = self.database_.getEvents(streamData,
                                                     limit: bulkSize)
                    
                    if (batch!.events.count > 1) {
                        let batchStr = ListToJsonStr(batch!.events)
                        let batchBytesSize = Int32(batchStr.characters.count *
                            sizeof(Character))
                        
                        if (batchBytesSize <= self.bulkBytesSize_) {
                            break
                        }
                        
                        let ceilValue = ceil(Float(batchBytesSize) /
                            Float(self.bulkBytesSize_))
                        bulkSize = Int32(Float(bulkSize) / ceilValue);
                    } else {
                        break
                    }
                }
                
                self.printLog("bulkSize: \(bulkSize)")
                self.printLog("batch count: \(batch!.events.count)")
                self.printLog("batch evetns: \(batch!.events)")
                
                if (batch!.events.count != 0) {
                    self.flushData(streamData, batch: batch!)
                } else {
                    self.dispatchSemapthore()
                }
                
            } else {
                self.printLog("Wrong stream name '\(streamName)'!")
                self.dispatchSemapthore()
            }
        }
    }
    
    /**
     Dispatch semaphore wrapper
     */
    func dispatchSemapthore() {
        dispatch_semaphore_signal(self.semaphore_)
    }
    
    /**
     Flush data to server of specific stream
     
     - parameter stream: Name of the stream
     */
    public func flush(streamName: String) {
        flushAsync(streamName, checkSize: false)
    }
    
    /**
     Flush all data to server
     */
    public func flush() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            let streamsList: [StreamData] = self.database_.getStreams()
            for stream in streamsList {
            
                objc_sync_enter(self.flushLock)
                if self.isFlushRunned[stream.name] != nil &&
                    self.isFlushRunned[stream.name] == true {
                    self.printLog("Flush runned \(stream.name)")
                    objc_sync_exit(self.flushSizedLock)
                    continue
                }
            
                self.isFlushRunned[stream.name] = true
                objc_sync_exit(self.flushLock)

                self.flush(stream.name)
            }
        }
    }
    
    /**
     Prints the log
     
     - parameter logData: Log data
     */
    func printLog(logData: String) {
        if (self.isDebug_) {
            print(TAG + ": \(logData)\n")
        }
    }
}
