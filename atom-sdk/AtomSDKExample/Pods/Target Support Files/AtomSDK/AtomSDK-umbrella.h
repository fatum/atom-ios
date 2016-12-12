#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ISAtom.h"
#import "ISAtomTracker.h"
#import "ISResponse.h"
#import "ISUtils.h"

FOUNDATION_EXPORT double AtomSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char AtomSDKVersionString[];

