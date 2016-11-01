//
//  ViewController.m
//  AtomSDKExample
//
//  Created by Valentine.Pavchuk on 10/26/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ViewController.h"

#import "ISAtom.h"

#import "ISRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ISAtom* atomSDK = [[ISAtom alloc] init];
    
    [atomSDK enableDebug:true];
    [atomSDK putEventWithStream:@"test" data:@"data" method:IS_GET];
    
    NSMutableDictionary* headers_ = [[NSMutableDictionary alloc] init];
    
    [headers_ setObject:@"ios" forKey:@"x-ironsource-atom-sdk-type"];
    [headers_ setObject:@"V1.0.0" forKey:@"x-ironsource-atom-sdk-version"];
    [headers_ setObject:@"application/json" forKey:@"Content-type"];
    
    ISRequest* request = [[ISRequest alloc] initWithUrl:@"https://google.com" data:@"test"
                                                headers:headers_ isDebug:true];
    
    [request get];
    
    NSLog(@"Init atom sdk!");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
