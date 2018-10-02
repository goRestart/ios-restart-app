//
//  AdAdapter.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 17/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AdAdapterDelegate;

/**
 * The `AdAdapter` protocol allows the AdsNative SDK to interact with native ad objects obtained
 * from third-party ad networks. An object that adopts this protocol acts as a wrapper for a native
 * ad object, translating its proprietary interface into a common one that the AdsNative SDK can
 * understand.
 *
 * An object that adopts this protocol must implement the `nativeAssets` property to specify a
 * dictionary of assets, such as title and text, that should be rendered as part of a native ad.
 * When possible, you should place values in the returned dictionary such that they correspond to
 * the pre-defined keys in the AdAssets header file.
 *
 * An adopting object must additionally implement -displayContentForURL:rootViewController:completion:
 * to supply the behavior that should occur when the user interacts with the ad.
 *
 * Optional methods of the protocol allow the adopting object to define when and how impressions
 * and interactions should be tracked.
 */
@protocol AdAdapter <NSObject>

@required

/**
 * Provides a dictionary of all publicly accessible assets (such as title and text) for the
 * native ad.
 *
 * When possible, you should place values in the returned dictionary such that they correspond to
 * the pre-defined keys in the AdConstants header file.
 */
@property (nonatomic, readonly) NSMutableDictionary *nativeAssets;

/**
 * The default click-through URL for the ad.
 *
 * This may safely be set to nil if your network doesn't expose this value (for example, it may only
 * provide a method to handle a click, lacking another for retrieving the URL itself).
 */
@property (nonatomic, readonly) NSURL *defaultClickThroughURL;

/**
 * A boolean which represents where the ad whether another rendering class should be chosen.
 *
 * The reason a backup would be required is because some ad responses may not contain an icon
 * image url. If that happens, a backup rendering class (which does not define icon image) may be defined
 * to loads native assets into. The backup rendering class should implement the `ANAdRendering` protocol as well.
 *
 * If this is nil, then the backup class is not required and assets can be loaded into the main rendering class.
 */
@property (nonatomic, readonly) BOOL isBackupClassRequired;

/** @name Handling Ad Interactions */

@optional

/**
 * Tells the object to open the specified URL using an appropriate mechanism.
 *
 * @param URL The URL to be opened.
 * @param controller The view controller that should be used to present the modal view controller.
 * @param completionBlock The block to be executed when the action defined by the URL has been
 * completed, returning control to the application.
 *
 * Your implementation of this method should either forward the request to the underlying
 * third-party ad object (if it has built-in support for handling ad interactions), or open an
 * in-application modal web browser or a modal App Store controller.
 */
- (void)displayContentForURL:(NSURL *)URL
          rootViewController:(UIViewController *)controller
                  completion:(void (^)(BOOL success, NSError *error))completionBlock;

/**
 * Determines whether NativeAd should track impressions
 *
 * If not implemented, this will be assumed to return NO, and NativeAd will track impressions.
 * If this returns YES, then NativeAd will defer to the AdAdapterDelegate callbacks to
 * track impressions.
 */
- (BOOL)enableThirdPartyImpressionTracking;

/**
 * Determines whether NativeAd should track clicks
 *
 * If not implemented, this will be assumed to return NO, and NativeAd will track clicks.
 * If this returns YES, then NativeAd will defer to the AdAdapterDelegate callbacks to
 * track clicks.
 */
- (BOOL)enableThirdPartyClickTracking;

/**
 * Tracks an impression for this ad.
 *
 * To avoid reporting discrepancies, you should only implement this method if the third-party ad
 * network requires impressions to be reported manually.
 */
- (void)trackImpression;

/**
 * Tracks a click for this ad.
 *
 * To avoid reporting discrepancies, you should only implement this method if the third-party ad
 * network requires clicks to be reported manually.
 */
- (void)trackClick;

/**
 * The `AdAdapterDelegate` to send messages to as events occur.
 *
 * The `delegate` object defines several methods that you should call in order to inform AdsNative
 * of interactions with the ad. This delegate needs to be implemented if third party impression and/or
 * click tracking is enabled.
 */
@property (nonatomic, weak) id<AdAdapterDelegate> delegate;

/**
 * Specifies how long your ad must be on screen before an impression is tracked.
 *
 * When a view containing a native ad is rendered and presented, the AdsNative SDK begins tracking the
 * amount of time the view has been visible on-screen in order to automatically record impressions.
 * This value represents the time required for an impression to be tracked.
 *
 * The default value is `kDefaultRequiredSecondsForImpression`.
 */
@property (nonatomic, readonly) NSTimeInterval requiredSecondsForImpression;

/** @name Responding to an Ad Being Attached to a View */

/**
 * This method will be called when your ad's content is about to be loaded into a view.
 *
 * @param view A view that will contain the ad content.
 *
 * You should implement this method if the underlying third-party ad object needs to be informed
 * of this event.
 */
- (void)willAttachToView:(UIView *)view;

/**
 * This method will be called when your ad's content is removed from a view.
 *
 * @param view A view that did contain the ad content.
 *
 * You should implement this method if the underlying third-party ad object needs to be informed
 * of this event while not invalidating the ad.
 */
-  (void)didDetachFromView:(UIView *)view;

/**
 * If it returns YES, then the publisher can implement the `nativeAdDidClick` callback and implement
 * their own way of handling how to take the user to the landing page after the native ad 
 * has been clicked.
 * Defaults to NO.
 */
- (BOOL)canOverrideClick;

/**
 * Determines whether NativeAd is a media (video) ad or not
 *
 * If not implemented, this will be assumed to return NO.
 * If this returns YES, then NativeAd will load be informed
 * that a media view asset is to be loaded.
 */
- (BOOL)isMediaView;

/** The `isMediaView` method must be implemented and returned with "Yes" for the following methods and properties to come into effect. **/

/**
 * Some 3rd party SDK networks do not handle visibility tracking for the media view that they provide. 
 * If this method returns YES, the AdsNative SDK will handle visibility tracking on the media view.
 *
 * Defaults to NO
 */
- (BOOL)handleMediaViewVisibility;

/*
 * The percentage of the media view that should be visible before `mediaDidComeIntoView` of
 * `mediaDidGoOutOfView` is called.
 * Defaults to 50.0
 */
@property (nonatomic, readonly) float mediaViewVisibilityPercent;

/**
 * Called when the media view comes into view. The media view can come into view if it is scrolled 
 * into view or if the app comes to foreground and the media view is visibile.
 */
- (void)mediaDidComeIntoView;

/**
 * Called when the media view goes out of view. The media view can go out of view if it is scrolled 
 * out of view or if the app goes into the background.
 */
- (void)mediaDidGoOutOfView;

@end
