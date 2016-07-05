//
//  IronSourceAtom.swift
//  AtomSDK
//
//  Created by g8y3e on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation
import sqlite3

/// Atom callback type definition
public typealias AtomCallback = (Response) -> Void

/// Atom simple SDK
public class IronSourceAtom {
    let TAG = "IronSourceAtom"
    let API_VERSION_ = "V1.0.1"
    
    var endpoint_ = "http://track.atom-data.io/"
    var authKey_ = ""
    
    var isDebug_ = false
    
    var headers_: Dictionary<String, String>
    
    /**
     API Constructor
     */
    public init() {
        headers_ = Dictionary<String, String>()
        headers_["x-ironsource-atom-sdk-type"] = "ios"
        headers_["x-ironsource-atom-sdk-version"] = self.API_VERSION_
    }
    
    /**
     Enabling print debug information
     
     - parameter isDebug: if set to <c>true</c> is debug.
     */
    public func enableDebug(isDebug: Bool) {
        self.isDebug_ = isDebug
    }
    
    /**
     Set Auth Key for stream
     
     - parameter authKey: Secret key of stream.
     */
    public func setAuth(authKey: String) {
        self.authKey_ = authKey
    }
    
    /**
     Set endpoint for send data
     
     - parameter endpoint: Address of server
     */
    public func setEndpoint(endpoint: String) {
        self.endpoint_ = endpoint
    }
    
    /**
     Send single data to Atom server.
     
     - parameter stream:   Stream name for saving data in db table
     - parameter data:     User data to send
     - parameter method:   POST or GET method for do request
     - parameter callback: Get response data
     */
    public func putEvent(stream: String, data: String, method: HttpMethod,
                         callback: AtomCallback?) {
        
        let jsonData = getRequestData(stream, data: data)
        sendRequest(self.endpoint_, data: jsonData, method: method,
                         callback: callback)
    }
    
    /**
     Send multiple events data to Atom server.
     
     - parameter stream:   Stream name for saving data in db table
     - parameter data:     User data to send
     - parameter callback: Get response data
     */
    public func putEvents(stream: String, data: [String],
                          callback: AtomCallback?) {
        let listJson = ListToJsonStr(data)
        
        printLog ("List to json: \(listJson)")
        let jsonData = getRequestData(stream, data: listJson)
        
        sendRequest(self.endpoint_ + "bulk", data: jsonData,
                         method: HttpMethod.POST, callback: callback)
    }
    
    /**
     Send multiple events data to Atom server.
     
     - parameter stream:   Stream name for saving data in db table
     - parameter data:     User data to send
     - parameter callback: Get response data
     */
    public func putEvents(stream: String, data: String,
                          callback: AtomCallback?) {
        let jsonData = getRequestData(stream, data: data)
        
        self.sendRequest(self.endpoint_ + "bulk", data: jsonData,
                         method: HttpMethod.POST, callback: callback)
    }
    
    /**
     Check health of server
     
     - parameter callback: For receive response from server
     */
    public func health(callback: AtomCallback?) {
        self.sendRequest(self.endpoint_ + "health", data: "",
                         method: HttpMethod.GET, callback: callback)
    }
    
    /**
     Send data to server
     
     - parameter url:      For server address
     - parameter data:     For request data
     - parameter method:   For POST or GET method
     - parameter callback: For receive response from server
     */
    func sendRequest(url: String, data: String, method: HttpMethod,
                     callback: AtomCallback?) {
        let request = Request(url: url, data: data, callback: callback,
                              headers: self.headers_, isDebug: self.isDebug_)
        
        if method == HttpMethod.GET {
            request.get()
        } else {
            request.post()
        }
    }
    
    /**
     Create request json data
     
     - parameter stream: Stream name for saving data in db table
     - parameter data:   User data to send
     
     - returns: Json string
     */
    func getRequestData(stream: String, data: String, bulk: Bool = false) -> String {
        let hash = (self.authKey_ == "") ? "" : EncodeHmac(data, key: self.authKey_)
        
        var eventObject = Dictionary<String, NSObject>()
        eventObject["table"] = stream
        eventObject["data"] = data
        if (hash != "") {
            eventObject["auth"] = hash
        }
        if (bulk) {
            eventObject["bulk"] = true
        }
        
        let jsonStr = ObjectToJsonStr(eventObject)
        
        printLog("Request json: \(jsonStr)")
        
        return jsonStr
    }
    
    /**
     Prints the log.
     
     - parameter logData: Log data.
     */
    func printLog(logData: String) {
        if (self.isDebug_) {
            print(TAG + ": \(logData)\n")
        }
    }
}
