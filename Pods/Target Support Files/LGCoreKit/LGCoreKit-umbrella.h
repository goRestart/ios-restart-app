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

#import "lgcorekit-Bridging-Header.h"
#import "LGCoreKit.h"

FOUNDATION_EXPORT double LGCoreKitVersionNumber;
FOUNDATION_EXPORT const unsigned char LGCoreKitVersionString[];

