//
//  ANNativeAdDelegate.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 20/10/15.
//  Copyright © 2015 AdsNative. All rights reserved.
//
#import "ANNativeAdTrackerDelegate.h"

@class PMNativeAd;
/**
 * The delegate of an `PMNativeAd` object must adopt the `ANNativeAdDelegate` protocol. It must
 * implement `nativeAdDidLoad` and `nativeAd:didFailWithError:` methods. 
 *
 * It is used for implementing single native ad requests and can be ignored for stream content.
 */
@protocol ANNativeAdDelegate <NSObject>

@required

/**
 * Tells the delegate when a native ad request has succeeded
 *
 * @param nativeAd: The `PMNativeAd` object containing the ad response
 */
- (void)anNativeAdDidLoad:(PMNativeAd *)nativeAd;

/**
 * Tells the delegate when a native ad request has failed
 *
 * @param nativeAd: Will be nil in this case
 * @param error: An error describing the failure.
 */
- (void)anNativeAd:(PMNativeAd *)nativeAd didFailWithError:(NSError *)error;

@end
