//
//  ISBatch.h
//  AtomSDK
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief Holds batch events
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
 * @brief Last ID received from DB
 */
@property int lastID;

/**
 *  Batch constructor
 *
 *  @param events List of events
 *  @param lastID Last ID received from DB
 */
-(id)initWithEvents: (NSArray*)events lastID: (int)lastID;

@end
