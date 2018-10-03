//
//  ANNativeAdTrackerDelegate.h

//  Created by Arvind Bharadwaj on 11/01/16.
//  Copyright © 2016 AdsNative. All rights reserved.
//
@class PMNativeAd;

@protocol ANNativeAdTrackerDelegate <NSObject>

@optional

/**
 * Tells the delegate when an impression for a native ad has been recorded
 */
- (void)anNativeAdDidRecordImpression;

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
- (BOOL)anNativeAdDidClick:(PMNativeAd *)nativeAd;

/**
 * Tells the delegate when the ad is about to leave the application (usually on ad click or adchoices icon click)
 */
- (void)anNativeAdWillLeaveApplication;

@end
