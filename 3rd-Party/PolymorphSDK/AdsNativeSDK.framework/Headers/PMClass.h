//
//  PMClass.h
//
//  Created by Arvind Bharadwaj on 15/11/17.
//  Copyright © 2017 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ANAdRequestTargeting.h"
#import "Constants.h"

@protocol PMClassDelegate;
@class PMNativeAd;
@class PMBannerView;

@interface PMClass : NSObject

@property (nonatomic, weak) id<PMClassDelegate> delegate;
@property (nonatomic, strong) NSString *adUnitID;

/*
 * default requestType is REQUEST_TYPE_NATIVE.
 * If request type is REQUEST_TYPE_BANNER or REQUEST_TYPE_ALL, then size needs to be passed
 */
- (instancetype)initWithAdUnitID:(NSString *)adUnitId requestType:(PM_REQUEST_TYPE)requestType withBannerSize:(CGSize)size;
- (void)loadPMAd;
- (void)loadPMAdWithTargeting:(ANAdRequestTargeting *)targeting;

#pragma mark - PM_REQUEST_TYPE_BANNER ONLY
/* The following methods are for banner requests only. It will be ignored if the request type is not PM_REQUEST_TYPE_BANNER */
/**
 * Stops the ad view from periodically loading new advertisements.
 *
 * By default, an ad view is allowed to automatically load new advertisements if a refresh interval
 * has been configured on the Polymorph website. This method prevents new ads from automatically loading,
 * even if a refresh interval has been specified.
 *
 * As a best practice, you should call this method whenever the ad view will be hidden from the user
 * for any period of time, in order to avoid unnecessary ad requests. You can then call
 * `startAutomaticallyRefreshingContents` to re-enable the refresh behavior when the ad view becomes
 * visible.
 *
 * @see startAutomaticallyRefreshingContents
 */
- (void)stopAutomaticallyRefreshingContents;

/**
 * Causes the ad view to periodically load new advertisements in accordance with user-defined
 * refresh settings on the Polymorph website.
 *
 * Calling this method is only necessary if you have previously stopped the ad view's refresh
 * behavior using `stopAutomaticallyRefreshingContents`. By default, an ad view is allowed to
 * automatically load new advertisements if a refresh interval has been configured on the Polymorph
 * website. This method has no effect if a refresh interval has not been set.
 *
 * @see stopAutomaticallyRefreshingContents
 */
- (void)startAutomaticallyRefreshingContents;

/**
 * Cancels any existing ad requests and requests a new ad from the Polymorph ad server.
 */
- (void)forceRefreshAd;

/**
 * This is set when you want PM banner ads to not be rendered into webview immediately. This is
 * done in case you don't want impressions to be tracked immediately upon successful ad response.
 * If this is set, PMBannerViews' `renderDelayedAd` needs to be called to render the ad into view.
 */
@property (nonatomic, assign) BOOL requestDelayedAd;
@end


@protocol PMClassDelegate <NSObject>

@required
- (UIViewController *)pmViewControllerForPresentingModalView;

@optional
/*
 * The following methods are conditionally mandatory. If the request type is PM_REQUEST_TYPE_NATIVE,
 * then the banner methods can be ignored and vice-versa.
 */

/* Banner Methods */
/* @required if request type is anything but PM_REQUEST_TYPE_NATIVE */
- (void)pmBannerAdDidLoad:(PMBannerView *)adView;
- (void)pmBannerAdDidFailToLoad:(PMBannerView *)view withError:(NSError *)error;
/* optional */
- (void)pmWillLeaveApplicationFromBannerAd:(PMBannerView *)view;
/*
 * Called only if you make a delayed load request for Polymorph Banner ads. It will NOT
 * be called for third-party mediated banner ads irrespective of delayed ad requests.
 */
- (void)pmBannerAdDidRender:(PMBannerView *)view;

/* Native Methods */
/* @required if request type is anything but PM_REQUEST_TYPE_BANNER */
- (void)pmNativeAdDidLoad:(PMNativeAd *)nativeAd;
- (void)pmNativeAd:(PMNativeAd *)nativeAd didFailWithError:(NSError *)error;

/* optional */

/**
 * Tells the delegate when an impression for a native ad has been recorded
 */
- (void)pmNativeAdDidRecordImpression;

/**
 * Tells the delegate when a click for a native ad click has happened
 *
 * @return: Boolean indicating whether publisher will handle ad click or not. Defaults to 'NO'.
 * If 'yes', then publisher must extract the `kNativeLandingUrlKey` from the nativeAssets to
 * get the landing url which the user must be taken to.
 *
 * Note: This return value is only for direct sold ads and api networks. For third party SDKs that do not
 * handle clicks on their own, this can be implemented by setting the `canOverrideClick` method to YES.
 *
 * If you wish to handle clicks only for your own direct ads, the `providerName` property in the nativeAd
 * object can be used to determine where the ad has come from. For direct ads, the provider name will have
 * a value "adsnative". For api network ads it will have "s2s" as its value and for other SDK networks, it
 * will have the name of the network adapter as its value, eg - "****NativeCustomEvent"
 */
- (BOOL)pmNativeAdDidClick:(PMNativeAd *)nativeAd;

/**
 * Tells the delegate when the ad is about to leave the application (usually on ad click or adchoices icon click)
 */
- (void)pmNativeAdWillLeaveApplication;

@end
