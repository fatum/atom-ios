//
//  ISBatch.h
//  AtomSDK
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief Holder of events data
 */
@interface ISBatch : NSObject {
    NSArray* events_;
    int lastID_;
}

/*!
 * @brief List of events
 */
@property NSArray* events;

/*!
 * @brief Last Id getted from DB
 */
@property int lastID;

/**
 *  Batch contructor
 *
 *  @param events List of events
 *  @param lastID List of events
 */
-(id)initWithEvents: (NSArray*)events lastID: (int)lastID;

@end
