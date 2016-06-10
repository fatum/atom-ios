//
//  BulkData.swift
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 6/10/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/// For hold all event for specific stream
public class BulkData {
    var data_: [String]
    
    /**
     Bulk data contructor
     */
    public init() {
        self.data_ = [String]()
    }
    
    /**
     Adds the data.
     
     - parameter data: String data.
     */
    public func addData(data: String) {
        self.data_.append(data)
    }
    
    /**
     Gets the size.
     
     - returns: Size of bulk data
     */
    public func getSize() -> Int {
        return self.data_.count
    }
    
    /**
     Get data list
     
     - returns: Return ref to bulk data
     */
    public func getData() -> [String] {
        return self.data_
    }
    
    /**
     Get data as json string
     
     - returns: Json string from bulk data
     */
    public func getStringData() -> String {
        return ObjectToJsonStr(self.data_)
    }
    
    /**
     Clearing all data from bulk
     */
    public func clearData() {
        self.data_.removeAll()
    }
}