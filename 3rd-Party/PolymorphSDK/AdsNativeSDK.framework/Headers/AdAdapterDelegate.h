//
//  AdAdapterDelegate.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 17/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//
@protocol AdAdapter;
/**
 * Classes that conform to the `AdAdapter` protocol can have a delegate object
 * `AdAdapterDelegate`. This delegate can then be used to communicate native ad
 * events back to the AdsNative SDK.
 */

@protocol AdAdapterDelegate <NSObject>

@required

/**
 * Asks the delegate for a view controller to use for presenting modal content 
 * Eg - An in-app browser that can appear when an ad is clicked.
 *
 * @return A view controller that should be used for presenting modal content.
 */
- (UIViewController *)viewControllerToPresentModalView;

@optional

/**
 * This method is called before the backing native ad logs an impression.
 *
 * @param adAdapter You should pass `self` to allow the AdsNative SDK to associate this event with the
 * correct instance of your ad adapter.
 */
- (void)nativeAdWillLogImpression:(id<AdAdapter>)adAdapter;

/**
 * This method is called when the user interacts with the ad.
 *
 * @param adAdapter You should pass `self` to allow the AdsNative SDK to associate this event with the
 * correct instance of your ad adapter.
 */
- (void)nativeAdDidClick:(id<AdAdapter>)adAdapter;

/**
 * Tells the delegate when the ad is about to leave the application (usually on ad click or adchoices icon click)
 */
- (void)nativeAdWillLeaveApplication:(id<AdAdapter>)adAdapter;
@end
