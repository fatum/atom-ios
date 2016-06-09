//
//  Request.swift
//  AtomSDK
//
//  Created by g8y3e on 6/8/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/// For make async HTTP requests to server
public class Request {
    var url_: String
    var data_: String
    var isDebug_: Bool
    
    var callback_: AtomCallback?
    var headers_: Dictionary<String, String>
    
    /**
     Constructor for Request
     
     - parameter url:      For server address.
     - parameter data:     For sending data.
     - parameter callback: For get response data.
     - parameter headers:  For sending headers.
     - parameter isDebug:  if set to <c>true</c> is debug.
     */
    public init(url: String, data: String, callback: AtomCallback?,
                headers: Dictionary<String, String>, isDebug: Bool) {
        self.url_ = url
        self.data_ = data
        
        self.callback_ = callback
        self.isDebug_ = isDebug
        
        self.headers_ = headers
    }
    
    /**
     GET request to server
     */
    public func get() {
        let utf8str = self.data_.dataUsingEncoding(NSUTF8StringEncoding)
        let encodedUri = utf8str!.base64EncodedStringWithOptions(
            NSDataBase64EncodingOptions(rawValue: 0))
        
        let urlWithGet = self.url_ + "?data=" + encodedUri
        
        printLog("URL: \(urlWithGet)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithGet)!)
        request.HTTPMethod = "GET"
        
        self.sendRequest(request)
    }
    
    /**
     POST request to server
     */
    public func post() {
        printLog("URL: \(self.url_)")
        
        let request = NSMutableURLRequest(URL: NSURL(string: self.url_)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = self.data_.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.sendRequest(request)
    }
    
    /**
     Send and read response from server
     
     - parameter request: Object with request information.
     */
    func sendRequest(request: NSMutableURLRequest) {
        let session = NSURLSession.sharedSession()
        
        for (key, value) in self.headers_ {
          request.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data,
            response, error -> Void in
            var status = -1
            var errorStr: String = ""
            var dataStr: String = ""
            
            if(error != nil) {
                errorStr = error!.localizedDescription
            } else {
                dataStr = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                self.printLog("Body: \(dataStr)")
                
                status = (response as! NSHTTPURLResponse).statusCode
            }
            
            self.callback_?(Response(error: errorStr, data: dataStr, status: status))
        })
        
        task.resume()
    }
    
    /**
     Prints the log.
     
     - parameter logData: Log data.
     */
    func printLog(logData: String) {
        if (self.isDebug_) {
            print(logData)
        }
    }
}