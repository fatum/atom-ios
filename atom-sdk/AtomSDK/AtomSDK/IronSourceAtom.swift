//
//  IronSourceAtom.swift
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

public class IronSourceAtom {
    let API_VERSION_ = "V1.0.0"
    
    var endpoint_ = "https://track.atom-data.io/"
    var authKey_ = ""
    
    var isDebug_ = false
        
    public init() {
    }
    
    public func enableDebug(isDebug : Bool) {
        self.isDebug_ = isDebug
    }
    
    public func setAuth(authKey : String) {
        self.authKey_ = authKey
    }
    
    public func setEndpoint(endpoint : String) {
        self.endpoint_ = endpoint
    }
    
    public func putEvent(stream : String, data : String, method : HttpMethod) {
        
    }
    
    public func putEvents(stream : String, data : String) {
        
    }
}
