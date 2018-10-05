//
//  CustomEventDelegate.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 24/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PMNativeAd;
@class CustomEvent;

/**
 * Instances of your custom subclass of `CustomEvent` will have an
 * `CustomEventDelegate` delegate object. You use this delegate to communicate progress
 * (such as whether an ad has loaded successfully) back to the AdsNative SDK.
 */
@protocol CustomEventDelegate <NSObject>

/**
 * This method is called when the ad and all required ad assets are loaded.
 *
 * @param event You should pass `self` to allow the AdsNative SDK to associate this event with the
 * correct instance of your custom event.
 * @param adObject An `NativeAd` object, representing the ad that was retrieved.
 */
- (void)nativeCustomEvent:(CustomEvent *)event didLoadAd:(PMNativeAd *)adObject;

/**
 * This method is called when the ad or any required ad assets fail to load.
 *
 * @param event You should pass `self` to allow the AdsNative SDK to associate this event with the
 * correct instance of your custom event.
 * @param error (*optional*) You may pass an error describing the failure.
 */
- (void)nativeCustomEvent:(CustomEvent *)event didFailToLoadAdWithError:(NSError *)error;


@end
