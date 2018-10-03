//
//  ANStoreKitProvider.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 06/10/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= AN_IOS_6_0
#import <StoreKit/StoreKit.h>
#endif

@interface ANStoreKitProvider : NSObject

+ (BOOL)deviceHasStoreKit;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= AN_IOS_6_0
+ (SKStoreProductViewController *)buildController;
#endif

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= AN_IOS_6_0
@protocol ANSKStoreProductViewControllerDelegate <SKStoreProductViewControllerDelegate>
#else
@protocol ANSKStoreProductViewControllerDelegate
#endif
@end