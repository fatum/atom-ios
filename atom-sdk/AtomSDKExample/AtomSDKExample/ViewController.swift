//
//  ViewController.swift
//  AtomSDKExample
//
//  Created by g8y3e on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import UIKit
import AtomSDKSwift
import Foundation

class ViewController: UIViewController {
    var api_: IronSourceAtom?
    var apiTracker_: IronSourceAtomTracker?
    var test = "Data test"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        func callback(response: Response) {
            print("From callback 1: \(response)")
            print("From callback (data): \(response.data)")
            print("From callback (error): \(response.error)")
            print("From callback (status): \(response.status)")
        }
        
        //Simple Atom SDK
        self.api_ = IronSourceAtom()
        self.api_!.enableDebug(true)
        self.api_!.setAuth("<YOUR_AUTH_KEY>")
        
        // Atom Tracker SDK
        self.apiTracker_ = IronSourceAtomTracker()
        self.apiTracker_!.enableDebug(true)
        self.apiTracker_!.setAuth("<YOUR_AUTH_KEY>")
        self.apiTracker_!.setBulkSize(3)
        self.apiTracker_!.setFlushInterval(2)
        self.apiTracker_!.setBulkBytesSize(10 * 1024)
        self.apiTracker_!.setEndpoint("http://track.atom-data.io/")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet var textArea_: UITextView!
    
    func postCallback(response: Response) {
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

    }
   
    @IBAction func buttonPostPressed(sender: UIButton) {
        self.api_!.putEvent("ibtest",
                            data: "{\"strings\":\"data 42\"}",
                            method: HttpMethod.POST, callback: postCallback)
    }
    
    @IBAction func buttonGetPressed(sender: UIButton) {
        func callback(response: Response) {
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
            
            let responseStr = "{\n\t\"error\": \(errorStr), " +
                "\n\t\"data\": \(dataStr), " +
                "\n\t\"status\": \(statusStr)\n}"
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.textArea_.text = responseStr
            }
        }
        
        self.api_!.putEvent("ibtest",
                           data: "{\"test\":\"test\"}",
                           method: HttpMethod.GET, callback: callback)
    }
    
    
    @IBAction func buttonBulkPressed(sender: UIButton) {
        func callback2(response: Response) {
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
            
            let responseStr = "{\n\t\"error\": \(errorStr), " +
                    "\n\t\"data\": \(dataStr), " +
                    "\n\t\"status\": \(statusStr)\n}"
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.textArea_.text = responseStr //Yay!
            }
        }
        
        self.api_!.health(nil)
        
        self.api_!.putEvents("ibtest",
                            data: ["{\"test\":\"test\"}", "{\"test\":\"test 2\"}"],
                            callback: callback2)
    }
    
    @IBAction func buttonTackPressed(sender: UIButton) {
        self.apiTracker_!.track("ibtest",
                                data: "{\"strings\": \"data 42\"}")
    }
    
    @IBAction func buttonFlushPressed(sender: UIButton) {
        self.apiTracker_!.flush()
    }
}

