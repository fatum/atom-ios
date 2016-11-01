//
//  ISRequest.m
//  AtomSDKExample
//
//  Created by g8y3e on 11/1/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISRequest.h"

@interface ISRequest()

-(void)printLog: (NSString*)logData;

-(void)sendRequest: (NSMutableURLRequest*)request;

@end

@implementation ISRequest

-(id)initWithUrl: (NSString*)url data: (NSString*)data
         headers: (NSMutableDictionary<NSString*, NSString*>*)headers
        callback: (ISRequestCallback) callback
         isDebug: (BOOL)isDebug {
    self = [super init];
    
    if (self) {
        self->url_ = url;
        self->data_ = data;
        self->headers_ = headers;
        
        self->isDebug_ = isDebug;
        
        self->callback_ = callback;
    }
    
    return self;
}

-(id)initWithUrl:(NSString *)url data:(NSString *)data
         headers:(NSMutableDictionary<NSString *,NSString *> *)headers
         isDebug:(BOOL)isDebug {
    return [self initWithUrl:url data:data headers:headers callback:nil
                     isDebug:isDebug];
}

-(void)get {
    NSString* encodedUri = [self->data_
                            stringByAddingPercentEncodingWithAllowedCharacters:
                            [NSCharacterSet URLHostAllowedCharacterSet]];

    NSString* urlWithGet = [NSString stringWithFormat:@"%@%@%@",
                            self->url_, @"?data=", encodedUri];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:urlWithGet]];
    
    [request setHTTPMethod:@"GET"];
    
    [self sendRequest:request];
}

-(void)post {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:self->url_]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[NSString stringWithFormat:@"%lu",
                       (unsigned long)[self->data_ length]]
        forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[self->data_ dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendRequest:request];
}

-(void)sendRequest: (NSMutableURLRequest*)request {
    for (NSString* key in self->headers_) {
        NSString* value = [self->headers_ objectForKey:key];
        
        [request setValue:value forHTTPHeaderField:key];
    }
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration
                                                defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration: configuration
                                                          delegate: self
                                                     delegateQueue: nil];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request
            completionHandler:^(NSData* data, NSURLResponse* response,
                                NSError* error) {
                long status = -1;
                NSString* errorStr = @"";
                NSString* dataStr = @"";
            
                if (error == nil) {
                    errorStr = [error localizedDescription];
                } else {
                    dataStr = [[NSString alloc] initWithData:data
                                                    encoding: NSUTF8StringEncoding];
                    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
                    status = [httpResponse statusCode];
                }
                
                [self printLog:[NSString stringWithFormat:@"Reponse: %ld - data: %@",
                                status, self->data_]];
                
                if (self->callback_ != nil) {
                    self->callback_([[ISResponse alloc] initWithData: dataStr
                                                               error: errorStr
                                                              status: status]);
                }
            }];
                                      
    [dataTask resume];
}

-(void)printLog: (NSString*)logData {
    if (self->isDebug_) {
        NSLog(@"%@: %@",  NSStringFromClass([self class]), logData);
    }
}

@end
