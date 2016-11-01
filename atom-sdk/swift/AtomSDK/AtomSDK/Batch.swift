//
//  Batch.swift
//  AtomSDK
//
//  Created by g8y3e on 6/16/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/// Holder of events data
public class Batch {
    /// List of events
    public let events: [String]
    /// Last Id getted from DB
    public let lastId: Int32
    
    /**
     Batch contructor
     
     - parameter events: List of events
     - parameter lastId: Last Id getted from DB
     */
    public init(events: [String], lastId: Int32) {
        self.events = events
        self.lastId = lastId
    }
}