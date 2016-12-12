//
//  ViewController.swift
//  AtomSDKExample
//
//  Created by g8y3e on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import UIKit
import AtomSDK
import Foundation

class ViewController: UIViewController {
    var api_: ISAtom?
    var apiTracker_: ISAtomTracker?
    var test = "Data test"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        func callback(response: ISResponse) {
            print("From callback 1: \(response)")
            print("From callback (data): \(response.data)")
            print("From callback (error): \(response.error)")
            print("From callback (status): \(response.status)")
        }
        
        //Simple Atom SDK
        self.api_ = ISAtom()
        self.api_!.enableDebug(true)
      //  self.api_!.setAuth("<YOUR_AUTH_KEY>")
        
        // Atom Tracker SDK
        self.apiTracker_ = ISAtomTracker()
        self.apiTracker_!.enableDebug(true)
        self.apiTracker_!.setAuth("<YOUR_AUTH_KEY>")
        self.apiTracker_!.setBulkSize(3)
        self.apiTracker_!.setFlushInterval(10)
        self.apiTracker_!.setBulkBytesSize(10 * 1024)
        self.apiTracker_!.setEndPoint("http://track.atom-data.io/")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet var textArea_: UITextView!
    
    func postCallback(response: ISResponse) {
       
    }
   
    @IBAction func buttonPostPressed(sender: UIButton) {
        self.api_!.putEventWithStream("ibtest", data: "{\"strings\":\"data 42\"}",
            callback: { response in
                
            print("from class method \(self.test)")
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
            
            let responseStr = "{\n\t\"error\": \(errorStr), " +
                "\n\t\"data\": \(dataStr), " +
                "\n\t\"status\": \(statusStr)\n}"
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.textArea_.text = responseStr
            }
        })
    }
    
    @IBAction func buttonGetPressed(sender: UIButton) {
       /* func callback(response: ISResponse) {
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
            
            let responseStr = "{\n\t\"error\": \(errorStr), " +
                "\n\t\"data\": \(dataStr), " +
                "\n\t\"status\": \(statusStr)\n}"
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.textArea_.text = responseStr
            }
        } */
        
        self.api_!.putEventWithStream("ibtest", data: "{\"test\":\"test\"}",
                                      callback: {response in
            
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
            
            let responseStr = "{\n\t\"error\": \(errorStr), " +
                "\n\t\"data\": \(dataStr), " +
                "\n\t\"status\": \(statusStr)\n}"
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.textArea_.text = responseStr
            }
        })
    }
    
    
    @IBAction func buttonBulkPressed(sender: UIButton) {
        
        self.api_!.health()
        
        self.api_!.putEventsWithStream("ibtest",
            arrayData: ["{\"test\":\"test\"}", "{\"test\":\"test 2\"}"],
            callback: { response in
            
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
            
            let responseStr = "{\n\t\"error\": \(errorStr), " +
                "\n\t\"data\": \(dataStr), " +
                "\n\t\"status\": \(statusStr)\n}"
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.textArea_.text = responseStr //Yay!
            }

        })
    }
    
    @IBAction func buttonTackPressed(sender: UIButton) {
        self.apiTracker_!.trackWithStream("ibtest",
                                data: "{\"strings\": \"data 42\"}", token: "")
    }
    
    @IBAction func buttonFlushPressed(sender: UIButton) {
        self.apiTracker_!.flush()
    }
}

