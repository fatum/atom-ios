//
//  Batch.swift
//  AtomSDK
//
//  Created by g8y3e on 6/16/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

public class Batch {
    public let events: [String]
    public let lastId: Int32
    
    public init(events: [String], lastId: Int32) {
        self.events = events
        self.lastId = lastId
    }
}