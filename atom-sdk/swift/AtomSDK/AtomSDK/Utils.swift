//
//  Utils.swift
//  AtomSDK
//
//  Created by g8y3e on 6/8/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation
import Arcane

/**
 Convert Object to Json string
 
 - parameter data: object to convert
 
 - returns: Json string
 */
func ObjectToJsonStr(data: NSObject) -> String {
    var jsonData: NSData
    var jsonStr: String = ""
    
    do {
        jsonData = try NSJSONSerialization.dataWithJSONObject(data, options:  NSJSONWritingOptions(rawValue: 0))        
    } catch _ {
        //print("Convert error: \(error)")
        return jsonStr
    }
    
    jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
    return jsonStr
}

/**
 Convert List to Json Str
 
 - parameter data: List of json data str
 
 - returns: json string data
 */
func ListToJsonStr(data: [String]) -> String {
    return "[" + data.joinWithSeparator(",") + "]"
}

/**
 Encode data to SHA256
 
 - parameter input: Data to encode
 - parameter key:   For endcoding data
 
 - returns: encoded string
 */

func EncodeHmac(input: String, key: String) -> String {
    return HMAC.SHA256(input, key: key)!
}

/**
 Get current milliseconds
 
 - returns: current time in int64
 */
func CurrentTimeMillis() -> Int64 {
    let nowDouble = NSDate().timeIntervalSince1970
    return Int64(nowDouble * 1000)
}

