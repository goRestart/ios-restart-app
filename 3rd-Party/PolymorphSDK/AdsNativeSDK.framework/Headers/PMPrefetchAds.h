//
//  PMPrefetchAds.h
//  Sample App
//
//  Created by Arvind Bharadwaj on 31/07/17.
//  Copyright © 2017 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMNativeAd.h"
#import "PMBannerView.h"

@interface PMPrefetchAds : NSObject

+ (instancetype)getInstance;
- (void)setAd:(PMNativeAd *)nativeAd;
- (PMNativeAd *)getAd;
- (void)clearCache;
- (void)getSize;
- (PMBannerView *)getBannerAd;
- (void)setBannerAd:(PMBannerView *)bannerAd;

@end
