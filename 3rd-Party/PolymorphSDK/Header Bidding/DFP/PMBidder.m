//
//  PMBidder.m
//  Sample App
//
//  Created by Arvind Bharadwaj on 13/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//
#import "PMBidder.h"

@interface PMBidder()

@property (nonatomic, strong) PMNativeAd *nativeAd;
@property (nonatomic, strong) PMClass *pmClass;
@property (nonatomic, strong) PMBannerView *pmBannerView;

@property (nonatomic, strong) GADAdLoader *gAdLoader;
@property (nonatomic, strong) DFPRequest *dfpRequest;
@property (nonatomic, strong) NSString *pmAdUnitID;
@property (nonatomic, weak) id<GADAdLoaderDelegate> delegate;

@property (nonnull, strong) DFPBannerView *dfpBannerView;

@property (nonatomic, strong) UIViewController *controller;
@end

static NSString *EcpmKey = @"ecpm";

@implementation PMBidder

- (instancetype)initWithPMAdUnitID:(NSString *)adUnitID
{
    self = [super init];
    self.pmAdUnitID = adUnitID;
    
    return self;
}

# pragma mark - Native Methods
- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller
{
    [self startWithAdLoader:gAdLoader viewController:controller dfpRequest:[DFPRequest request]];
}

- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller dfpRequest:(DFPRequest *)request
{
    self.gAdLoader = gAdLoader;
    self.controller = controller;
    self.dfpRequest = request;
    LogSetLevel(LogLevelDebug);
    //clear PM ad cache before making a fresh request
    [[PMPrefetchAds getInstance] clearCache];
    
    self.pmClass = [[PMClass alloc] initWithAdUnitID:self.pmAdUnitID requestType:PM_REQUEST_TYPE_NATIVE withBannerSize:CGSizeMake(0,0)];
    self.pmClass.delegate = self;
    
    ANAdRequestTargeting *targeting = [ANAdRequestTargeting targeting];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    [keywords addObject:@"&hb=1"];
    targeting.keywords = keywords;
    
    [self.pmClass loadPMAdWithTargeting:targeting];
    
}

#pragma mark - Banner Methods

- (void)startWithBannerView:(DFPBannerView *)dfpBannerView viewController:(UIViewController *)controller withBannerSize:(CGSize)bannerSize
{
    [self startWithBannerView:dfpBannerView viewController:controller dfpRequest:[DFPRequest request] withBannerSize:bannerSize];
}

- (void)startWithBannerView:(DFPBannerView *)dfpBannerView viewController:(UIViewController *)controller dfpRequest:(DFPRequest *)request withBannerSize:(CGSize)bannerSize
{
    self.gAdLoader = nil;
    self.dfpBannerView = dfpBannerView;
    self.controller = controller;
    self.dfpRequest = request;
    
    //clear PM ad cache before making a fresh request
    [[PMPrefetchAds getInstance] clearCache];
    
    self.pmClass = [[PMClass alloc] initWithAdUnitID:self.pmAdUnitID requestType:PM_REQUEST_TYPE_BANNER withBannerSize:bannerSize];
    [self.pmClass stopAutomaticallyRefreshingContents];
    self.pmClass.delegate = self;
    self.pmClass.requestDelayedAd = YES;
    
    ANAdRequestTargeting *targeting = [ANAdRequestTargeting targeting];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    [keywords addObject:@"&hb=1"];
    targeting.keywords = keywords;
    
    [self.pmClass loadPMAdWithTargeting:targeting];
}

#pragma mark - Native-Banner Methods
- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller withBannerSize:(CGSize)bannerSize
{
    [self startWithAdLoader:gAdLoader viewController:controller dfpRequest:[DFPRequest request] withBannerSize:bannerSize];
}

- (void)startWithAdLoader:(GADAdLoader *)gAdLoader viewController:(UIViewController *)controller dfpRequest:(DFPRequest *)request withBannerSize:(CGSize)bannerSize
{
    self.gAdLoader = gAdLoader;
    self.controller = controller;
    self.dfpRequest = request;
    
    //clear PM ad cache before making a fresh request
    [[PMPrefetchAds getInstance] clearCache];
    
    self.pmClass = [[PMClass alloc] initWithAdUnitID:self.pmAdUnitID requestType:PM_REQUEST_TYPE_ALL withBannerSize:bannerSize];
    self.pmClass.delegate = self;
    self.pmClass.requestDelayedAd = YES;
    
    ANAdRequestTargeting *targeting = [ANAdRequestTargeting targeting];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    [keywords addObject:@"&hb=1"];
    targeting.keywords = keywords;
    
    [self.pmClass loadPMAdWithTargeting:targeting];
}

#pragma mark - <PMCLassDelegate>
- (void)pmNativeAdDidLoad:(PMNativeAd *)nativeAd
{
    self.nativeAd = nativeAd;
    [[PMPrefetchAds getInstance] setAd:self.nativeAd];
    
    if ([nativeAd.nativeAssets objectForKey:kNativeEcpmKey] != nil) {
        NSString *ecpmAsString = [NSString stringWithFormat:@"%.2f", self.nativeAd.biddingEcpm];
        LogDebug(@"Making DFP request with ecpm: %@", ecpmAsString);
        
        NSMutableDictionary *targeting = [NSMutableDictionary dictionaryWithDictionary:(self.dfpRequest.customTargeting ? self.dfpRequest.customTargeting : @{})];
        [targeting setObject:ecpmAsString forKey:EcpmKey];
        
        self.dfpRequest.customTargeting = targeting;
    } else {
        LogDebug(@"Ecpm not present in Polymorph response. Loading default DFP ad.");
    }
    
    [self.gAdLoader loadRequest:self.dfpRequest];
    
}

- (void)pmNativeAd:(PMNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    [self.gAdLoader loadRequest:self.dfpRequest];
}

- (void)pmBannerAdDidLoad:(PMBannerView *)adView
{
    self.pmBannerView = adView;
    [[PMPrefetchAds getInstance] setBannerAd:self.pmBannerView];
    
    if (self.pmBannerView.biddingEcpm != -1) {
        NSString *ecpmAsString = [NSString stringWithFormat:@"%.2f", self.pmBannerView.biddingEcpm];
        
        LogDebug(@"Making DFP request with ecpm: %@", ecpmAsString);
        
        NSMutableDictionary *targeting = [NSMutableDictionary dictionaryWithDictionary:(self.dfpRequest.customTargeting ? self.dfpRequest.customTargeting : @{})];
        [targeting setObject:ecpmAsString forKey:EcpmKey];
        
        self.dfpRequest.customTargeting = targeting;
    } else {
        LogDebug(@"Ecpm not present in Polymorph response. Loading default DFP ad.");
    }
    
    if (self.gAdLoader != nil) {
        [self.gAdLoader loadRequest:self.dfpRequest];
    } else {
        [self.dfpBannerView loadRequest:self.dfpRequest];
    }
}

- (void)pmBannerAdDidFailToLoad:(PMBannerView *)view withError:(NSError *)error
{
    if (self.gAdLoader != nil) {
        [self.dfpBannerView loadRequest:self.dfpRequest];
    } else {
        [self.dfpBannerView loadRequest:self.dfpRequest];
    }
}

- (UIViewController *)pmViewControllerForPresentingModalView {
    return self.controller;
}

@end
