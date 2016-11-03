//
//  ISDatabaseAdapter.h
//  AtomSDKExample
//
//  Created by g8y3e on 11/2/16.
//  Copyright © 2016 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISSQLiteHandler.h"

@interface ISDatabaseAdapter : NSObject
{
    ISSQLiteHandler* dbHandler_;
}

-(id)init;

-(void)enableDebug: (BOOL)isDebug;


@end
