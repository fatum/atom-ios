//
//  HttpMethod.swift
//  AtomSDK
//
//  Created by g8y3e on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import Foundation

/**
 Types of HTTP methods
 */
public enum HttpMethod: String {
    /**
     * Get request
     */
    case GET = "GET"
    
    /**
     * Post request with body content
     */
    case POST = "POST"
}