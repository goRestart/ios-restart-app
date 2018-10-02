//
//  AdsNativeSDK.h
//  AdsNativeSDK
//
//  Created by Arvind Bharadwaj on 29/10/15.
//  Copyright © 2015 AdsNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//! Project version number for AdsNativeSDK.
FOUNDATION_EXPORT double AdsNativeSDKVersionNumber;

//! Project version string for AdsNativeSDK.
FOUNDATION_EXPORT const unsigned char AdsNativeSDKVersionString[];

#import <AdsNativeSDK/ANAdPositions.h>
#import <AdsNativeSDK/ANClientAdPositions.h>
#import <AdsNativeSDK/ANServerAdPositions.h>
#import <AdsNativeSDK/ANAdRendering.h>
#import <AdsNativeSDK/ANAdRequestTargeting.h>
#import <AdsNativeSDK/PMNativeAd.h>
#import <AdsNativeSDK/ANNativeAdDelegate.h>
#import <AdsNativeSDK/ANNativeAdTrackerDelegate.h>
#import <AdsNativeSDK/AdAdapter.h>
#import <AdsNativeSDK/Logging.h>
#import <AdsNativeSDK/AdAdapterDelegate.h>
#import <AdsNativeSDK/ANCollectionViewAdPlacerDelegate.h>
#import <AdsNativeSDK/ANTableViewAdPlacerDelegate.h>
#import <AdsNativeSDK/CustomEvent.h>
#import <AdsNativeSDK/CustomEventDelegate.h>
#import <AdsNativeSDK/SDKConfigs.h>
#import <AdsNativeSDK/AdErrors.h>
#import <AdsNativeSDK/AdAssets.h>
#import <AdsNativeSDK/URLResolver.h>
#import <AdsNativeSDK/URLActionInfo.h>
#import <AdsNativeSDK/ANAVFullScreenPlayerViewController.h>
#import <AdsNativeSDK/AdDestinationDisplayAgent.h>
#import <AdsNativeSDK/InstanceProvider.h>
#import <AdsNativeSDK/Constants.h>
#import <AdsNativeSDK/ANCollectionViewAdPlacer.h>
#import <AdsNativeSDK/ANTableViewAdPlacer.h>
#import <AdsNativeSDK/PMPrefetchAds.h>
#import <AdsNativeSDK/PMClass.h>
#import <AdsNativeSDK/PMBannerView.h>

@interface AdsNativeSDK : NSObject

/**
 * Returns the AdsNativeSDK singleton object.
 *
 * @return The AdsNative singleton object.
 */
+ (AdsNativeSDK *)sharedInstance;

/**
 * A Boolean value indicating whether the AdsNative SDK should automatically fetch location to
 * derive targeting information for location-based ads.
 *
 * The SDK will periodically listen for location updates when set to YES. This will happen only if
 * the location services are enabled and the user has authorized the same.
 *
 * Default is set to YES.
 *
 * @param enableLocationUpdates A Boolean value indicating whether the SDK should listen for location updates.
 */
@property (nonatomic, assign) BOOL enableLocationUpdates;

@end
