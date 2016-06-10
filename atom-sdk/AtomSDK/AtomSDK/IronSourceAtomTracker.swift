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
    var flushInterval_: Double = 10
    var bulkSize_: Int = 1000
    var bulkBytesSize_: Int = 64 * 1024
    
    var timer_:NSTimer?
    
    var api_: IronSourceAtom
    
    var isDebug_: Bool = false
    
    var bulkDataMap_: Dictionary<String, BulkData>
    
    /**
     API Tracker constructor
     */
    public init() {
        self.api_ = IronSourceAtom()
        bulkDataMap_ = Dictionary<String, BulkData>()
    }
    
    /**
     API Tracker destructor
     */
    deinit {
        self.timer_?.invalidate()
        self.timer_ = nil
    }
    
    /**
     Enabling print debug information
     
     - parameter isDebug: If set to true is debug.
     */
    public func enableDebug(isDebug: Bool) {
        self.isDebug_ = isDebug
        
        self.api_.enableDebug(isDebug)
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
    public func setBulkSize(bulkSize: Int) {
        self.bulkSize_ = bulkSize
    }
    
    /**
     Set Bult data bytes size
     
     - parameter bulkBytesSize: Size in bytes
     */
    public func setBulkBytesSize(bulkBytesSize: Int) {
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
    public func track(stream: String, data: String) {
        if (self.bulkDataMap_[stream] == nil) {
            self.bulkDataMap_[stream] = BulkData()
        }
        
        let bulkData = self.bulkDataMap_[stream]
        bulkData!.addData(data)
        let bulkStr = bulkData!.getStringData()
        let bulkBytesSize = bulkStr.characters.count * sizeof(Character)
        
        self.printLog("Bulk bytes size: \(bulkBytesSize)")
        
        if (bulkData?.getSize() >= self.bulkSize_ || bulkBytesSize >= self.bulkBytesSize_) {
            flush(stream)
        }
        
        if (self.timer_ == nil) {
            self.printLog("Create flush timer!")
            self.timer_ = NSTimer.scheduledTimerWithTimeInterval(self.flushInterval_,
                            target: self, selector: #selector(IronSourceAtomTracker.timerFlush),
                            userInfo: nil, repeats: true)
        }
    }
    
    /**
     Wrapper for flush method in timer
     */
    @objc func timerFlush() {
        self.flush()
    }
    
    
    /**
     Send data to atom server
     
     - parameter stream:   Name of the stream
     - parameter data:     Info for sending
     - parameter dataSize: Size of info's
     - parameter method:   Http method (POST or GET)
     - parameter callback: callback for retry
     */
    func sendData(stream: String, data: String, dataSize: Int = 1,
                  method: HttpMethod = HttpMethod.POST, callback: AtomCallback?) {
        if (dataSize == 1) {
            self.api_.putEvent(stream, data: data, method: method,
                               callback: callback)
        } else if (dataSize > 1) {
            self.api_.putEvents(stream, data: data, callback: callback)
        }
    }
    
    /**
     Flush bulk data object
     
     - parameter stream:   Name of stream to flush
     - parameter bulkData: Bulk data object
     */
    func flushData(stream: String, bulkData: BulkData) {
        var bulkDataStr:String = ""
        var bulkSize: Int = 0
            
        objc_sync_enter(self)
            bulkDataStr = bulkData.getStringData()
            bulkSize = bulkData.getSize()
            bulkData.clearData()
        objc_sync_exit(self)
        
        var callback: AtomCallback?
        var timeout:Double = 1
        
        callback = {response -> Void in
            if (response.error != "") {
                if (response.status >= 500 || response.status < 0) {
                    dispatch_sync(dispatch_get_main_queue()) {
                        let fireDate = timeout + CFAbsoluteTimeGetCurrent()
                        if (timeout < 10 * 60) {
                            timeout = timeout * 2
                            let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0,   0, 0) { _ in
                                self.sendData(stream, data: bulkDataStr, dataSize: bulkSize,
                                              method: HttpMethod.POST, callback: callback)
                            }
                            CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
                        } else {
                            self.printLog("Server not response more then 10min.")
                        }
                    }
                } else {
                self.printLog("Server error: \(response.error)")
                }
            } else {
                self.printLog("Server response: \(response.data)")
            }
        }
        
        sendData(stream, data: bulkDataStr, dataSize: bulkSize,
                 method: HttpMethod.POST, callback: callback)
    }
    
    /**
     Flush data to server of specific stream
     
     - parameter stream: Name of the stream
     */
    public func flush(stream: String) {
        if (stream.characters.count > 0) {
            if (self.bulkDataMap_[stream] != nil) {
                let bulkData = self.bulkDataMap_[stream]
                flushData(stream, bulkData: bulkData!)
            }
        } else {
            printLog("Wrong stream name '\(stream)'!")
        }
    }
    
    /**
     Flush all data to server
     */
    public func flush() {
        for (stream, bulkData) in self.bulkDataMap_ {
            flushData(stream, bulkData: bulkData)
        }
    }
    
    /**
     Prints the log
     
     - parameter logData: Log data
     */
    func printLog(logData: String) {
        if (self.isDebug_) {
            print(logData)
        }
    }
}
