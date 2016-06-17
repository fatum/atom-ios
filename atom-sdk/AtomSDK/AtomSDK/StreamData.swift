//
//  StreamData.swift
//  AtomSDK
//
//  Created by g8y3e on 6/15/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/// Holder of stream data
public class StreamData {
    // Stream name
    public var name: String
    // Stream Auth key
    public var token: String
    
    /**
     Stream Data contructor
     
     - parameter name:  Stream name
     - parameter token: Stream Auth key
     */
    public init(name: String = "", token: String = "") {
        self.name = name
        self.token = token
    }
}
