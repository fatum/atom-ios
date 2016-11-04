//
//  ISAtomTracker.m
//  AtomSDKExample
//
//  Created by g8y3e on 11/3/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import "ISAtomTracker.h"

static double DEFAULT_FLUSH_INTERVAL = 10;
static int DEFAULT_BULK_SIZE = 1000;
static int DEFAULT_BULK_BYTES_SIZE = 64 * 1024;

@interface ISAtomTracker()

-(void)invalidateTimerFlush;

-(void)initTimerFlush;

-(void)timerFlush;

-(void)flushAsyncWithStream: (NSString*)stream checkSize: (BOOL)isCheckSize;

-(void)flushDataWithStreamData: (ISStreamData*)streamData batch: (ISBatch*)batch;

-(void)sendDataWithStreamData: (ISStreamData*)streamData data: (NSString*)data
                     dataSize: (unsigned long)dataSize method: (ISHttpMethod)method
                     callback: (ISRequestCallback)callback;

-(void)dispatchSemaphore;

-(void)printLog: (NSString*)logData;

@end

@implementation ISAtomTracker

-(id)init {
    self = [super init];
    
    if (self) {
        self->flushInterval_ = DEFAULT_FLUSH_INTERVAL;
        self->bulkSize_ = DEFAULT_BULK_SIZE;
        self->bulkBytesSize_ = DEFAULT_BULK_BYTES_SIZE;
        
        self->isFirst_ = true;
        self->isRunTimeFlush_ = true;
        
        self->flushLock_ = [[NSLock alloc] init];
        self->flushSizedLock_ = [[NSLock alloc] init];
        
        self->isFlushSizedRunned_ = [[NSMutableDictionary alloc] init];
        self->isFlushRunned_ = [[NSMutableDictionary alloc] init];
        
        self->semaphore_ = dispatch_semaphore_create(0);
        
        self->api_ = [[ISAtom alloc] init];
        
        // init database
        self->database_ = [[ISDatabaseAdapter alloc] init];
        [self->database_ create];
    }
    return self;
}

-(void)dealloc {
    [self invalidateTimerFlush];
}

-(void)invalidateTimerFlush {
    if (self->timer_) {
        [self->timer_ invalidate];
        self->timer_ = nil;
    }
}

-(void)initTimerFlush {
    [self invalidateTimerFlush];
    
    [self printLog:[NSString stringWithFormat:
                   @"Create flush timer with intervals: %f",
                    self->flushInterval_]];
    self->timer_ = [NSTimer scheduledTimerWithTimeInterval:self->flushInterval_
                            target:self selector:@selector(timerFlush)
                            userInfo:nil repeats:true];
}

-(void)enableDebug: (BOOL)isDebug {
    self->isDebug_ = isDebug;
    
    [self->api_ enableDebug:isDebug];
    [self->database_ enableDebug:isDebug];
}

-(void)setAuth: (NSString*)authKey {
    [self->api_ setAuth:authKey];
}

-(void)setEndPoint: (NSString*)endPoint {
    [self->api_ setEndPoint:endPoint];
}

-(void)setBulkSize: (int)bulkSize {
    self->bulkSize_ = bulkSize;
}

-(void)setBulkBytesSize: (int)bulkBytesSize {
    self->bulkBytesSize_ = bulkBytesSize;
}

-(void)setFlushInterval: (double)flushInterval {
    self->flushInterval_ = flushInterval;
}

-(void)trackWithStream: (NSString*)stream data: (NSString*)data
                 token: (NSString*)token {
    if ([token length] == 0) {
        token = [self->api_ authKey];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int rowsCount = [self->database_ addEventWithStreamData:
                         [[ISStreamData alloc] initWithName:stream token:token]
                                                           data:data];
        
        if (rowsCount >= self->bulkSize_) {
            //
        }
    });
}

-(void)flushAsyncWithStream: (NSString*)stream checkSize: (BOOL)isCheckSize {
    if (isCheckSize) {
        [self->flushSizedLock_ lock];
        
        if ([self->isFlushSizedRunned_ objectForKey:stream] != nil &&
            [self->isFlushSizedRunned_[stream] boolValue]) {
            [self printLog:[NSString stringWithFormat:
                            @"Flush size runned for %@!", stream]];
            [self->flushSizedLock_ unlock];
        }
        
        [self->isFlushSizedRunned_ setObject:[NSNumber numberWithBool:true]
                                      forKey:stream];
        [self->flushSizedLock_ unlock];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self printLog:[NSString stringWithFormat:
                        @"Dispatch start for stream: %@", stream]];
         
        dispatch_semaphore_wait(self->semaphore_, DISPATCH_TIME_FOREVER);
        [NSThread sleepForTimeInterval:0.2];
        
        [self printLog:[NSString stringWithFormat:
                        @"Dispatch end for stream: %@", stream]];
        
        if (isCheckSize) {
            [self->flushSizedLock_ lock];
            [self->isFlushSizedRunned_ setObject:[NSNumber numberWithBool:false]
                                          forKey:stream];
            [self->flushSizedLock_ unlock];
            
            int eventCount = [self->database_ countWithStreamName:stream];
            if (eventCount < self->bulkSize_) {
                [self dispatchSemaphore];
                return;
            }
        } else {
            [self->flushLock_ lock];
            [self->isFlushSizedRunned_ setObject:[NSNumber numberWithBool:false]
                                          forKey:stream];
            [self->flushLock_ unlock];
        }
        
        if ([stream length] > 0) {
            ISBatch* batch;
            int bulkSize = self->bulkSize_;
            
            ISStreamData* streamData = [self->database_ getStreamWithName:stream];
            if (streamData == nil) {
                [self printLog:[NSString stringWithFormat:
                                @"Can't get stream data for stream: %@", stream]];
                return;
            }
            
            while (true) {
                batch = [self->database_ getEventsWithStreamData:streamData
                                                           limit:bulkSize];
                
                if (batch && [[batch events] count] > 1) {
                    NSString* batchStr = [ISUtils listToJsonStr:[batch events]];
                    NSUInteger batchBytesSize = [batchStr
                                lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                
                    if (batchBytesSize <= self->bulkBytesSize_) {
                        break;
                    }
                    
                    float ceilValue = ceil((float)batchBytesSize /
                                           (float)self->bulkBytesSize_);
                    bulkSize = (int)((float)bulkSize / ceilValue);
                } else {
                    break;
                }
            }
            
            [self printLog:[NSString stringWithFormat:
                            @"Bulk size: %i", bulkSize]];
            [self printLog:[NSString stringWithFormat:
                            @"Batch count: %lu", (unsigned long)[[batch events] count]]];
            [self printLog:[NSString stringWithFormat:
                            @"Batch events: %@", [[batch events] componentsJoinedByString:
                                                  @", "]]];
            
            if ([[batch events] count] != 0) {
                [self flushDataWithStreamData: streamData batch: batch];
            } else {
                [self dispatchSemaphore];
            }
        } else {
            [self printLog:@"Empty stream name!"];
            [self dispatchSemaphore];
        }
    });
}

-(void)flushDataWithStreamData: (ISStreamData*)streamData batch: (ISBatch*)batch {
    NSString* batchDataStr;
    
    if ([[batch events] count] == 1) {
        batchDataStr = [batch events][0];
    } else {
        batchDataStr = [ISUtils listToJsonStr:[batch events]];
    }
    
    unsigned long batchSize = [[batch events] count];
    
    __block ISRequestCallback callback;
    __block int64_t timeout = 1;
    
    static int MAX_TIMER_TIME = 10 * 60;
    
    callback = ^(ISResponse* response) {
        BOOL isOk = false;
        
        if ([[response error] length] != 0) {
            if ([response status] >= 500 || [response status] < 0) {
                self->isRunTimeFlush_ = false;
                
                dispatch_sync(dispatch_get_main_queue(), ^() {
                    int64_t delayInSeconds = timeout;
                    
                    if (timeout < MAX_TIMER_TIME) {
                        timeout = timeout * 2;
                        
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                                delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^() {
                            [self sendDataWithStreamData: streamData
                                                    data: batchDataStr
                                                dataSize: batchSize
                                                  method: IS_POST
                                                callback: callback];
                        });
                    } else {
                        self->isRunTimeFlush_ = true;
                        [self dispatchSemaphore];
                        
                        [self printLog:[NSString stringWithFormat:
                                        @"Server not response more than %i seconds!",
                                        MAX_TIMER_TIME]];
                    }
                });
            } else {
                [self printLog:[NSString stringWithFormat:@"Server error: %@",
                                [response error]]];
                isOk = true;
            }
        } else {
            [self printLog:[NSString stringWithFormat:@"Server response: %@",
                            [response data]]];
            isOk = true;
        }
        
        if (isOk) {
            self->isRunTimeFlush_ = true;
            [self->database_ deleteEventsWithStreamData:streamData
                                                 lastID:[batch lastID]];
            
            if ([self->database_ countWithStreamName:[streamData name]] == 0) {
                [self->database_ deleteStreamWithStreamData:streamData];
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^() {
                [self initTimerFlush];
            });
            
            [self dispatchSemaphore];
        }
    };
    
    [self sendDataWithStreamData:streamData data:batchDataStr dataSize:batchSize
                          method:IS_POST callback:callback];
}

-(void)sendDataWithStreamData: (ISStreamData*)streamData data: (NSString*)data
                     dataSize: (unsigned long)dataSize method: (ISHttpMethod)method
                     callback: (ISRequestCallback)callback {
    [self->api_ setAuth:[streamData token]];
    
    if (dataSize == 1) {
        [self->api_ putEventWithStream:[streamData name] data:data method:method
                              callback:callback];
    } else if (dataSize > 1) {
        [self->api_ putEventsWithStream:[streamData name] stringData:data
                               callback:callback];
    }
}

-(void)dispatchSemaphore {
    dispatch_semaphore_signal(self->semaphore_);
}

-(void)printLog: (NSString*)logData {
    if (self->isDebug_) {
        NSLog(@"%@: %@",  NSStringFromClass([self class]), logData);
    }
}

@end
