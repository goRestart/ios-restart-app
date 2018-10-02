//
//  PolymorphDFPNativeCustomEvent.m
//  Sample App
//
//  Created by Arvind Bharadwaj on 16/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//

#import "PolymorphDFPNativeCustomEvent.h"
#import "PolymorphDFPNativeAdAdapter.h"

NSString *const kPolymorphPlacementID = @"placementId";

@interface PolymorphDFPNativeCustomEvent()

@property (nonatomic, weak) UIViewController *viewController;

@end


@implementation PolymorphDFPNativeCustomEvent

- (void)requestNativeAdWithParameter:(NSString *)serverParameter request:(GADCustomEventRequest *)request adTypes:(NSArray *)adTypes options:(NSArray *)options rootViewController:(UIViewController *)rootViewController {
    
    PMNativeAd *cachedAd = [[PMPrefetchAds getInstance] getAd];
    if (cachedAd != nil) {
        self.viewController = rootViewController;
        [self anNativeAdDidLoad:cachedAd];
        
    } else {
        //if cached ad not present, then move on
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"no cached Polymorph Native ad found" forKey:NSLocalizedDescriptionKey];
        [self.delegate customEventNativeAd:self didFailToLoadWithError:[NSError errorWithDomain:@"Polymorph" code:204 userInfo:details]];
    }
    
}

- (BOOL)handlesUserClicks {
    return YES;
}


- (BOOL)handlesUserImpressions {
    return YES;
}

- (void)anNativeAdDidLoad:(PMNativeAd *)nativeAd
{
    PolymorphDFPNativeAdAdapter *adAdapter = [[PolymorphDFPNativeAdAdapter alloc] initWithPMNativeAd:nativeAd viewController:self.viewController];
    [self.delegate customEventNativeAd:self didReceiveMediatedNativeAd:adAdapter];
}

@end

