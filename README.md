# ironSource.atom SDK for IOS

[![License][license-image]][license-url]
[![Docs][docs-image]][docs-url]
[![Pods][pod-image]][pod-url]
[![Build status][travis-image]][travis-url]
[![Coverage Status][coverage-image]][coverage-url]

atom-ios is the official [ironSource.atom](http://www.ironsrc.com/data-flow-management) SDK for the IOS platform.

- [Installation](#installation)
- [Usage](#usage)
- [Signup](https://atom.ironsrc.com/#/signup)
- [Documentation](https://ironsource.github.io/atom-ios/)
- [Example](#example)

## Installation

### Installation from [CocoaPods](https://cocoapods.org/?q=atomsdk).
Add dependency in your pod file
```ruby
pod 'AtomSDK'
```

## Usage

### Tracker usage
Example of sending an event in Swift:
```swift
// initialize atom-sdk api object
var apiTracker_ = ISAtomTracker()
apiTracker_!.enableDebug(true)
apiTracker_!.setAuth("<YOUR_AUTH_KEY>")
apiTracker_!.setBulkSize(<BULK_COUNT>)
apiTracker_!.setBulkBytesSize(<MAX_BULK_SIZE_IN_BYTES>)
apiTracker_!.setEndPoint("https://track.atom-data.io/")

// track event
apiTracker_!.trackWithStream("<YOUR_STREAM_NAME>",
                                data: "{\"test\":\"test\"}")

// flush all data in tracker
apiTracker_!.flush()

```
Example of sending an event in Objective-C:
```objc
// initialize atom-sdk api object
ISAtomTracker* apiTracker_ = [[ISAtomTracker alloc] init];
[apiTracker_ enableDebug:true];
[apiTracker_ setBulkSize:<BULK_COUNT>];
[apiTracker_ setBulkBytesSize:<MAX_BULK_SIZE_IN_BYTES>];
[apiTracker_ setEndPoint:@"https://track.atom-data.io/"];

// track event
[apiTracker_ trackWithStream: @"<YOUR_STREAM_NAME>" data: @"{\"test\":\"test\"}"
                       token: @"<YOUR_AUTH_KEY>"];

// flush all data in tracker
[apiTracker_ flush];
```

### Low level API usage (putEvent and putEvents)
Example of sending an event in Swift:
```swift
// initialize atom-sdk api object
    var api_ = ISAtom()
    
    // print debug info in console
    api_!.enableDebug(true)
    api_!.setAuth("<YOUR_AUTH_KEY>")
    
    // send POST request
    api_!.putEventWithStream("<YOUR_STREAM_NAME>",
        data: "{\"test\":\"test\"}",
        callback: {response in
            
            let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
            let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
            let statusStr = "\(response.status)"
    })
    
    // send Bulk request
    api_!.putEventsWithStream("<YOUR_STREAM_NAME>",
                              arrayData: ["{\"test\":\"test\"}", "{\"test\":\"test\"}"],
                              callback: { response in
                                
                                let errorStr = (response.error == "") ? "nil" : "\"\(response.error)\""
                                let dataStr = (response.data == "") ? "nil" : "\"\(response.data)\""
                                let statusStr = "\(response.status)"
                                
                                let responseStr = "{\n\t\"error\": \(errorStr), " +
                                    "\n\t\"data\": \(dataStr), " +
                                    "\n\t\"status\": \(statusStr)\n}"
    })
    
    // check health of server
    api_!.health()
```
Example of sending an event in Objective-C:
```objc
// initialize atom-sdk api object
ISAtom* api_ = [[ISAtom alloc] init];

// print debug info in console
[api_ enableDebug:true];
[api_ setAuth: @"<YOUR_AUTH_KEY>"];

// send POST request
ISRequestCallback callback = ^(ISResponse* response) {
    // reponse data from server
};

[api_ putEventWithStream: @"<YOUR_STREAM_NAME>"
                    data: @"{\"test\":\"test\"}"
                callback: callback];

// send Bulk request
NSArray* data = [NSArray arrayWithObjects:@"{\"test\":\"test\"}", @"{\"test\":\"test\"}", nil];
[api_ putEventsWithStream: @"<YOUR_STREAM_NAME>"
                arrayData: data
                 callback: callback];

// check health of server
[api_ health];         
```

## Swift version
Also we have written on [swift](https://github.com/ironSource/atom-ios/tree/swift) version of SDK, but currently not supported.

## Example 
You can use our [example][example-url] for sending data to Atom:

![alt text][example]

## License
[MIT](LICENSE)

[docs-image]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-url]: https://ironsource.github.io/atom-ios/
[pod-image]: https://img.shields.io/cocoapods/v/AtomSDK.svg
[pod-url]: https://cocoapods.org/?q=AtomSDK

[travis-image]: https://travis-ci.org/ironSource/atom-ios.svg?branch=master
[travis-url]: https://travis-ci.org/ironSource/atom-ios
[coverage-image]: https://coveralls.io/repos/github/ironSource/atom-ios/badge.svg?branch=master
[coverage-url]: https://coveralls.io/github/ironSource/atom-ios?branch=master
[license-image]: https://img.shields.io/badge/license-MIT-blue.svg
[license-url]: LICENSE
[example]: https://cloud.githubusercontent.com/assets/1713228/15971662/08129c62-2f43-11e6-980d-66d36a41f961.png "example"
[example-url]: atom-sdk/AtomSDKExample
