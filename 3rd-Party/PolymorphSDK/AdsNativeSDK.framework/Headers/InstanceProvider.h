//
//  InstanceProvider.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 22/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdDestinationDisplayAgent.h"
#import "URLResolver.h"

typedef id(^SingletonProviderBlock)();


@class AdServerPinger;
@protocol AdServerPingerDelegate;

@class CustomEvent;
@protocol CustomEventDelegate;

@class AdSource;
@protocol AdSourceDelegate;

@class StreamAdPlacementData;
@class ANAdPositions;
@class AdPositionSource;
@class StreamAdPlacer;
@class GeoLocationProvider;

@class PMBannerCustomEvent;
@protocol PMBannerCustomEventDelegate;

@interface InstanceProvider : NSObject

+ (instancetype)sharedProvider;

#pragma mark - utils
- (GeoLocationProvider *)sharedGeoLocationProvider;

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL;
- (AdServerPinger *)buildAdServerPingerWithDelegate:(id<AdServerPingerDelegate>)delegate;

#pragma mark - URL Handling
- (URLResolver *)buildURLResolverWithURL:(NSURL *)URL completion:(URLResolverCompletionBlock)completion;
- (AdDestinationDisplayAgent *)buildAdDestinationDisplayAgentWithDelegate:(id<AdDestinationDisplayAgentDelegate>)delegate;

#pragma mark - Native
- (CustomEvent *)buildNativeCustomEventFromCustomClass:(Class)customClass
                                              delegate:(id<CustomEventDelegate>)delegate;

- (AdSource *)buildNativeAdSourceWithDelegate:(id<AdSourceDelegate>)delegate;

- (StreamAdPlacementData *)buildStreamAdPlacementDataWithPositioning:(ANAdPositions *)positioning;


- (StreamAdPlacer *)buildStreamAdPlacerWithViewController:(UIViewController *)controller adPositioning:(ANAdPositions *)positioning defaultAdRenderingClass:defaultAdRenderingClass;

#pragma mark - Banner
- (PMBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<PMBannerCustomEventDelegate>)delegate;
@end
