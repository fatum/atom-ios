//
//  Response.swift
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

public class Response {
    public var error: String
    public var data: String
    public var status: Int
    
    public init(error: String, data: String, status: Int) {
        self.error = error
        self.data = data
        self.status = status
    }
}