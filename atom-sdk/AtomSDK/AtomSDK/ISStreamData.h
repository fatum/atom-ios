//
//  ISStreamData.h
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief Holder of stream data
 */
@interface ISStreamData : NSObject
{
    NSString* name_;
    NSString* token_;
}

/*!
 * @brief Stream name
 */
@property NSString* name;

/*!
 * @brief Stream Auth key
 */
@property NSString* token;

/**
 *  Stream Data contructor
 *
 *  @param name      Stream name
 *  @param token     Stream Auth key
 *
 *  @return ISStreamData
 */
-(id)initWithName: (NSString*)name token: (NSString*)token;
-(id)init;

@end
