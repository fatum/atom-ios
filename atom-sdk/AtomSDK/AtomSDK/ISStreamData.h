//
//  ISStreamData.h
//  AtomSDK
//
//  Created by Valentine.Pavchuk on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief Holds Atom Stream data: name & auth token.
 */
@interface ISStreamData : NSObject
{
    NSString* name_;
    NSString* token_;
}

/*!
 * @brief Atom Stream name
 */
@property NSString* name;

/*!
 * @brief Atom Stream Auth key
 */
@property NSString* token;

/**
 *  Stream Data constructor
 *
 *  @param name      Atom Stream name
 *  @param token     Atom Stream Auth key
 *
 *  @return ISStreamData
 */
-(id)initWithName: (NSString*)name token: (NSString*)token;
-(id)init;

@end
