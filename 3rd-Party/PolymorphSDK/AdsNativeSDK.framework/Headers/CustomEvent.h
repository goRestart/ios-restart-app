//
//  CustomEvent.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 24/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import "CustomEventDelegate.h"

/**
 * The AdsNative SDK mediates third-party native ad networks using custom events. Custom events are
 * responsible for instantiating and manipulating native ad objects in the third-party SDK and
 * translating and communicating events from those objects back to the AdsNative SDK by notifying a
 * delegate.
 *
 * `CustomEvent` is a base class for custom events that support native ads. By implementing
 * subclasses of `CustomEvent` you can enable the AdsNative SDK to support a variety of
 * third-party ad networks.
 *
 * Your implementation should create a `NativeAd` object using an appropriate `AdAdapter`
 * for your network. Your custom event should also call the appropriate
 * `CustomEventDelegate` methods.
 *
 * At runtime, the AdsNative SDK will find and instantiate an `CustomEvent` subclass as needed
 * and invoke its `-requestAdWithCustomEventInfo:` method.
 */
@interface CustomEvent : NSObject

/** @name Requesting a Native Ad */

/**
 * Called when the AdsNative SDK requires a new native ad.
 *
 * When the AdsNative SDK receives a response indicating it should load a custom event, it will send
 * this message to your custom event class. Your implementation should load a native ad from a
 * third-party ad network.
 *
 * @param info A dictionary containing additional custom data associated with a given custom event
 * request. This data is configurable on the AdsNative website, and may be used to pass dynamic
 * information, such as publisher IDs.
 */
- (void)requestAdWithCustomEventInfo:(NSDictionary *)info;

/** @name Caching Image Resources */

/**
 * Downloads and pre-caches images.
 *
 * If your ad network does not provide built-in support for image caching, you may invoke this
 * method in your custom event implementation to pre-cache image assets. If you do call this method,
 * you should wait until the completion block is called before invoking the appropriate
 * success or failure callbacks on the `CustomEventDelegate`.
 *
 * @param imageURLs An array of `NSURL` objects representing image resource locations.
 * @param completionBlock A block that will be called after all download operations are complete.
 * If any image downloads do not complete successfully, the `errors` parameter will contain
 * error information about the failures.
 */
- (void)precacheImagesWithURLs:(NSArray *)imageURLs completionBlock:(void (^)(NSArray *errors))completionBlock;

/** @name Communicating with the AdsNative SDK */

/**
 * The `CustomEventDelegate` receives messages concerning the status of loading a native ad.
 *
 * The `delegate` object defines several methods that you should call in order to inform AdsNative
 * of the progress of your custom event.
 */
@property (nonatomic, weak) id<CustomEventDelegate> delegate;

@end
