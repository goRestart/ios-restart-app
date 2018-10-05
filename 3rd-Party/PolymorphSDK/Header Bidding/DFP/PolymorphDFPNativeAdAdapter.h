//
//  PolymorphDFPNativeAdAdapter.h
//  Sample App
//
//  Created by Arvind Bharadwaj on 16/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdsNativeSDK/AdsNativeSDK.h>

@class PMNativeAd;

@interface PolymorphDFPNativeAdAdapter : NSObject <GADMediatedNativeContentAd, GADMediatedNativeAppInstallAd, GADMediatedNativeAdDelegate>

- (instancetype)initWithPMNativeAd:(PMNativeAd *)nativeAd viewController:(UIViewController *)viewController;

@end
