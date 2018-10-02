//
//  PolymorphDFPBannerCustomEvent.h
//  Sample App
//
//  Created by Arvind Bharadwaj on 24/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdsNativeSDK/AdsNativeSDK.h>

@interface PolymorphDFPBannerCustomEvent : NSObject <GADCustomEventBanner>

@property (nonatomic, weak) id<GADCustomEventBannerDelegate> delegate;

@end
