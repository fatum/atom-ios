//
//  ViewController.swift
//  AtomSDKExample
//
//  Created by Valentine.Pavchuk on 6/7/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

import UIKit
import AtomSDK
import Foundation

class ViewController: UIViewController {
    var api_: IronSourceAtom?
    var apiTracker_: IronSourceAtomTracker?
    var test = "Data test"
    
    var i: Int = 0
    var j: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
       /* let db = DBAdapter(isDebug: true)
        db.upgrade(1, newVersion: 2)
        
        db.addEvent(StreamData(name: "wwww", token: "1"), data: "test 1")
        db.addEvent(StreamData(name: "wwww", token: "1"), data: "test 1 2")
        db.addEvent(StreamData(name: "rrrr", token: "1"), data: "test 1333")
        let count = db.addEvent(StreamData(name: "wwww", token: "1"), data: "test 2")
        
        print("Count: \(count)")
        
        //print("Count from method: \(db.count())")
       // db.vacuum()
        
        //print("Count from method: \(db.count())")
        
        let events = db.getEvents(StreamData(name: "wwww", token: "1"), limit: 10)
        
        let countDels = db.deleteEvents(StreamData(name: "wwww", token: "1"), lastId: 4)
        
        print("Count from method: \(db.count())")
        
        db.getEvents(StreamData(name: "rrrr", token: "1"), limit: 10)
        
        print("Events: \(events)")
        
        print("Streams: \(db.getStreams()[0])")
        */
        
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
        self.api_!.setAuth("I40iwPPOsG3dfWX30labriCg9HqMfL")
        
        self.apiTracker_ = IronSourceAtomTracker()
        self.apiTracker_!.enableDebug(true)
        self.apiTracker_!.setAuth("I40iwPPOsG3dfWX30labriCg9HqMfL")
        self.apiTracker_!.setBulkSize(3)
        self.apiTracker_!.setFlushInterval(100)
        self.apiTracker_!.setBulkBytesSize(10 * 1024)
        self.apiTracker_!.setEndpoint("http://track.atom-data.io/")
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
        j += 1
        self.api_!.putEvent("sdkdev_sdkdev.public.g8y3etest",
                            data: "{\"strings\":\"wwwwww \(j)\"}",
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
        
        self.api_!.putEvent("sdkdev_sdkdev.public.g8y3etest",
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
        
        self.api_!.putEvents("sdkdev_sdkdev.public.g8y3etest",
                            data: ["{\"test\":\"test\"}", "{\"test\":\"test 2\"}"],
                            callback: callback2)
    }
    
    @IBAction func buttonTackPressed(sender: UIButton) {
        self.apiTracker_!.track("sdkdev_sdkdev.public.g8y3etest",
                                data: "{\"strings\": \"XXXX \(i) XXXX\"}")
        i += 1
    }
    
    @IBAction func buttonTrack2Pressed(sender: UIButton) {
        self.apiTracker_!.track("sdkdev_sdkdev.public.atomtestkeyone",
                                data: "{\"message\": \"wwww \(i) wwwww\"}",
                                token: "I40iwPPOsG3dfWX30labriCg9HqMfL")
        
        i += 2
    }
    
    @IBAction func buttonFlushPressed(sender: UIButton) {
        self.apiTracker_!.flush()
    }
}

