//
//  PMBidder.h
//  Sample App
//
//  Created by Arvind Bharadwaj on 13/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AdsNativeSDK/AdsNativeSDK.h>

@protocol PMBidderDelegate;

@interface PMBidder : NSObject <PMClassDelegate>

- (instancetype)initWithPMAdUnitID:(NSString *)adUnitID;

#pragma mark - Native Methods
- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller;
- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller dfpRequest:(DFPRequest *)request;

#pragma mark - Banner Methods
- (void)startWithBannerView:(DFPBannerView *)dfpBannerView viewController:(UIViewController *)controller withBannerSize:(CGSize)bannerSize;
- (void)startWithBannerView:(DFPBannerView *)dfpBannerView viewController:(UIViewController *)controller dfpRequest:(DFPRequest *)request withBannerSize:(CGSize)bannerSize;

#pragma mark - Native-Banner Methods
- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller withBannerSize:(CGSize)bannerSize;
- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller dfpRequest:(DFPRequest *)request withBannerSize:(CGSize)bannerSize;
@end
