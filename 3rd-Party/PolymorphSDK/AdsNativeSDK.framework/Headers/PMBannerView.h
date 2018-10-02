//
//  PMBannerView.h
//
//  Created by Arvind Bharadwaj on 07/11/17.
//  Copyright © 2017 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AdDelegate.h"

@class ANAdRequestTargeting;
@class AdRequest;
@class SDKConfigs;

@protocol PMBannerViewDelegate;

/**
 * The PMBannerView class provides a view that can display banner advertisements.
 */

@interface PMBannerView : UIView

/** @name Initializing a Banner Ad */

/**
 * Initializes an PMBannerView with the given ad unit ID and banner size.
 *
 * @param adUnitId A string representing a Polymorph ad unit ID.
 * @return A newly initialized ad view corresponding to the given ad unit ID and size.
 */
- (id)initWithAdUnitId:(NSString *)adUnitId withSize:(CGSize)size;

/** @name Setting and Getting the Delegate */

/**
 * The delegate (`PMBannerViewDelegate`) of the ad view.
 *
 * @warning **Important**: Before releasing an instance of `PMBannerView`, you must set its delegate
 * property to `nil`.
 */
@property (nonatomic, weak) id<PMBannerViewDelegate> delegate;

/** @name Setting Request Parameters */

/**
 * The Polymorph ad unit ID for this ad view.
 */
@property (nonatomic, copy) NSString *adUnitId;

/**
 * The bidding ecpm rounded to the nearest decimal decided by the bidding interval.
 * The bidding interval default is 0.01 and can be modified on the server at an adunit level.
 * returns -1 if no ecpm is returned in the ad response
 */
@property (nonatomic, readonly) float biddingEcpm;

/**
 * This is set when you want PM banner ads to not be rendered into webview immediately. This is
 * done in case you don't want impressions to be tracked immediately upon successful ad response.
 * If this is set, PMBannerViews' `renderDelayedAd` needs to be called to render the ad into view.
 */
@property (nonatomic, assign) BOOL requestDelayedAd;

/**
 * The bidding interval which decides what the biddingEcpm will finally be rounded to the nearest
 * multiple of bidding interval
 **/
@property (nonatomic) float biddingInterval;

/*
 * Gets set only for PM banner ads and if making a delayed ad call using PMClass. This will get reset to NO if `renderDelayedAd` is
 * called following which the `adViewDidRenderAd:` callback gets fired.
 */
@property (nonatomic, assign) BOOL isUnRenderedPMAd;

/** @name Loading a Banner Ad */

/**
 * Requests a new ad from the Polymorph ad server.
 *
 * If the ad view is already loading an ad, this call will be ignored. You may use `forceRefreshAd`
 * if you would like cancel any existing ad requests and force a new ad to load.
 */
- (void)loadAd;

/*
 * Renders the ad into UIWebView. This is done incase you want to delay firing impressions. If you call loadAd
 * instead, then impression trackers get fired as soon as a valid ad is fetched from the PM server. This method works
 * for PM banner ads and not third-party SDK mediated ones. For mediated ads, their impression trackers fire on successful
 * ad response.
 */
- (void)renderDelayedAd;

/**
 * Requests a new ad from the Polymorph ad server with targeting parameters set.
 *
 * If the ad view is already loading an ad, this call will be ignored. You may use `forceRefreshAd`
 * if you would like cancel any existing ad requests and force a new ad to load.
 */
- (void)loadAdWithTargeting:(ANAdRequestTargeting *)targeting;

/**
 * Cancels any existing ad requests and requests a new ad from the Polymorph ad server.
 */
- (void)forceRefreshAd;

/** @name Handling Orientation Changes */

/**
 * Informs the ad view that the device orientation has changed.
 *
 * @param newOrientation The new interface orientation (after orientation changes have occurred).
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;


/** @name Obtaining the Size of the Current Ad */

/**
 * Returns the size of the current ad being displayed in the ad view.
 *
 * Ad sizes may vary between different ad networks. This method returns the actual size of the
 * underlying mediated ad. This size may be different from the original, initialized size of the
 * ad view. You may use this size to determine to adjust the size or positioning of the ad view
 * to avoid clipping or border issues.
 *
 * @returns The size of the underlying mediated ad.
 */
- (CGSize)adContentViewSize;

/** @name Managing the Automatic Refreshing of Ads */

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

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -

/**
 * The delegate of an `PMBannerView` object must adopt the `PMBannerViewDelegate` protocol. It must
 * implement `viewControllerToPresentAdView` to provide a root view controller from which
 * the ad view should present modal content.
 *
 * Optional methods of this protocol allow the delegate to be notified of banner success or
 * failure, as well as other lifecycle events.
 */

@protocol PMBannerViewDelegate <AdDelegate>

@optional

/** @name Detecting When a Banner Ad is Loaded */

/**
 * Sent when an ad view successfully loads an ad.
 *
 * Your implementation of this method should insert the ad view into the view hierarchy, if you
 * have not already done so.
 *
 * @param view The ad view sending the message.
 */
- (void)adViewDidLoadAd:(PMBannerView *)view;

/**
 * Sent when an ad view fails to load an ad.
 *
 * To avoid displaying blank ads, you should hide the ad view in response to this message.
 *
 * @param view The ad view sending the message.
 */
- (void)adViewDidFailToLoadAd:(PMBannerView *)view error:(NSError *)error;

/** @name Detecting When a User Interacts With the Ad View */

/**
 * Sent when a user is about to leave your application as a result of tapping
 * on an ad.
 *
 * Your application will be moved to the background shortly after this method is called.
 *
 * @param view The ad view sending the message.
 */
- (void)willLeaveApplicationFromAd:(PMBannerView *)view;

/**
 * Sent when an ad view successfully renders an ad.
 *
 * Your implementation of this method should insert the ad view into the view hierarchy, if you
 * have not already done so. This will only be called when PMBannerView's renderDelayedAd
 * method is called.
 *
 * @param view The ad view sending the message.
 */
- (void)adViewDidRenderAd:(PMBannerView *)view;

/* For PM_REQUEST_TYPE_ALL in PMClass */
- (AdRequest *)getAdRequestObject;
- (UIView *)getBannerAdResponse;
- (NSMutableDictionary *)getBannerCustomEventData;

@end
