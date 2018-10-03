//
//  AdDelegate.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 17/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//
#import "ANNativeAdTrackerDelegate.h"
@class SDKConfigs;
/**
 * The delegate of an `PMNativeAd` object must adopt the `AdDelegate` protocol. It must
 * implement `viewControllerToPresentModalView` to provide a root view controller from which
 * the ad view should present modal content.
 */
@protocol AdDelegate <ANNativeAdTrackerDelegate>

@optional
- (SDKConfigs *)getSDKConfigs;
@required

/**
 * Asks the delegate for a view controller to use for presenting modal content, such as the in-app
 * browser that can appear when an ad is tapped.
 *
 * @return A view controller that should be used for presenting modal content.
 */
- (UIViewController *)viewControllerToPresentAdModalView;

@end
