//
//  Utils.swift
//  AtomSDK
//
//  Created by g8y3e on 6/8/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation
import CommonCrypto

/**
 Convert Object to Json string
 
 - parameter data: object to convert
 
 - returns: Json string
 */
func ObjectToJsonStr(data: NSObject) -> String {
    var jsonData: NSData
    var jsonStr: String = ""
    do {
        jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
        jsonStr = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
    } catch let error as NSError {
        print(error)
    }
    
    return jsonStr
}

/**
 Encode data to SHA256
 
 - parameter input: Data to encode
 - parameter key:   For endcoding data
 
 - returns: encoded string
 */

func EncodeHmac(input: String, key: String) -> String {
    let str = input.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = Int(input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    
    let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
    
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    
    let keyStr = key.cStringUsingEncoding(NSUTF8StringEncoding)
    let keyLen = Int(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyStr!, keyLen, str!,
           strLen, result)
    
    let digest = NSMutableString()
    for i in 0..<digestLen {
        digest.appendFormat("%02x", result[i])
    }
    
    result.dealloc(digestLen)
    
    return digest as String
}

