//
//  ViewController.swift
//  AtomSDKExample
//
//  Created by Valentine.Pavchuk on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import UIKit
import AtomSDK

class ViewController: UIViewController {
    var api_: IronSourceAtom?
    var apiTracker_: IronSourceAtomTracker?
    var test = "Data test"
    
    var i: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        func callback(response: Response) {
            print("From callback 1: \(response)")
            print("From callback (data): \(response.data)")
            print("From callback (error): \(response.error)")
            print("From callback (status): \(response.status)")
        }
        
        
        //request.get()
        self.api_ = IronSourceAtom()
        self.api_!.enableDebug(true)
        self.api_!.setAuth("yYFxqzZj2AYO2ytya5hsPAwTbyY40b")
        
        self.apiTracker_ = IronSourceAtomTracker()
        self.apiTracker_!.enableDebug(true)
        self.apiTracker_!.setAuth("yYFxqzZj2AYO2ytya5hsPAwTbyY40b")
        self.apiTracker_!.setBulkSize(1)
        self.apiTracker_!.setEndpoint("https://track.atom-data.io1/")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.textArea_.text = responseStr //Yay!
        }

    }
   
    @IBAction func buttonPostPressed(sender: UIButton) {
        self.api_!.putEvent("g8y3eironsrc_g8y3e_test.public.g8y3etest12",
                            data: "{\"test\":\"test\"}",
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
                self.textArea_.text = responseStr //Yay!
            }

        }
        
        self.api_!.putEvent("g8y3eironsrc_g8y3e_test.public.g8y3etest",
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
        
        self.api_!.putEvents("g8y3eironsrc_g8y3e_test.public.g8y3etest",
                            data: ["{\"test\":\"test\"}", "{\"test\":\"test 2\"}"],
                            callback: callback2)
    }
    
    @IBAction func buttonTackPressed(sender: UIButton) {
        self.apiTracker_!.track("g8y3eironsrc_g8y3e_test.public.g8y3etest12",
                                data: "\(i)")
        i += 1
    }
    
    @IBAction func buttonFlushPressed(sender: UIButton) {
        self.apiTracker_!.flush()
    }
}

