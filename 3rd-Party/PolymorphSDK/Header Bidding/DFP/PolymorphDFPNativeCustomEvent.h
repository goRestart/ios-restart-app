//
//  PolymorphDFPNativeCustomEvent.h
//  Sample App
//
//  Created by Arvind Bharadwaj on 16/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdsNativeSDK/AdsNativeSDK.h>

@interface PolymorphDFPNativeCustomEvent : NSObject <GADCustomEventNativeAd>

@property (nonatomic, weak) id<GADCustomEventNativeAdDelegate> delegate;

@end
