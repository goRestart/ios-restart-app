//
//  PolymorphDFPNativeAdAdapter.m
//  Sample App
//
//  Created by Arvind Bharadwaj on 16/07/18.
//  Copyright © 2018 AdsNative. All rights reserved.
//

#import "PolymorphDFPNativeAdAdapter.h"

@interface PolymorphDFPNativeAdAdapter() <AdDelegate>

@property (nonatomic, weak) PMNativeAd *pmNativeAd;
@property (nonatomic, assign) BOOL isAppInstallAd;
@property (nonatomic, weak) UIViewController *viewController;

@end

static NSString *kPolymorphAdType = @"polymorph";
static NSString *kAdNetwork = @"adNetwork";

@implementation PolymorphDFPNativeAdAdapter

- (instancetype)initWithPMNativeAd:(PMNativeAd *)nativeAd viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.pmNativeAd = nativeAd;
        self.pmNativeAd.internalDelegate = self;
        self.viewController = viewController;
        
        self.isAppInstallAd = NO;
        
        if ([[self.pmNativeAd nativeAssets] objectForKey:kNativeCTATextKey] != nil &&
            [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] != nil) {
            self.isAppInstallAd = YES;
        }
    }
    
    return self;
}

#pragma mark - <GADMediatedNativeAd>
- (id<GADMediatedNativeAdDelegate>)mediatedNativeAdDelegate {
    return self;
}

- (NSDictionary *)extraAssets {
    NSMutableDictionary *assets = [NSMutableDictionary new];
    assets[kAdNetwork] = kPolymorphAdType;
    return assets;
}


#pragma mark - <GADMediatedNativeContentAd, GADMediatedNativeAppInstallAd>

- (NSString *)advertiser {
    return [[self.pmNativeAd nativeAssets] objectForKey:kNativeSponsoredKey];
}

- (NSString *)body {
    return [[self.pmNativeAd nativeAssets] objectForKey:kNativeTextKey];
}

- (NSString *)callToAction {
    return [[self.pmNativeAd nativeAssets] objectForKey:kNativeCTATextKey];
}

- (NSString *)headline {
    return [[self.pmNativeAd nativeAssets] objectForKey:kNativeTitleKey];
}

//list of images of type GADNativeAdImage
- (NSArray *)images {
    NSString *uri = [[self.pmNativeAd nativeAssets] objectForKey:kNativeMainImageKey];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:uri]]];
    
    return @[[[GADNativeAdImage alloc] initWithImage:image]];
}

//brand image for content ad
- (GADNativeAdImage *)logo {
    UIImage *image = nil;
    if ([[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIView class]]) {
        //return null as GADNativeAdImage doesnt support UIViews
        return NULL;
    } else if ([[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIImage class]]) {
        image = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
    } else if ([[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
        image = imageView.image;
    } else {
        NSURL *imageURL = [NSURL URLWithString:[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey]];
        image = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
    }
    
    if (image != nil)
        return [[GADNativeAdImage alloc] initWithImage:image];
    return NULL;
}

//icon image for app ad
- (GADNativeAdImage *)icon {
    
    UIImage *image = nil;
    if ([[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIView class]]) {
        UIView *iconImageView = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
        //check if image is of class type FBAdIconView then send back dummy image (cant send null as icon image is required) *hack!*
        if ([iconImageView isKindOfClass: NSClassFromString(@"FBAdIconView")]) {
            //hit a 1x1 image for faster download
            NSURL *i = [NSURL URLWithString:@"https://d3m9pgf48clj74.cloudfront.net/media/nw-523/d5e38fa0-9ebb-4f68-835b-c672f11c3e88.jpg"];
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:i]];
            return [[GADNativeAdImage alloc] initWithImage:image];
        }
    } else if ([[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIImage class]]) {
        image = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
    } else if ([[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
        image = imageView.image;
    } else {
        NSURL *imageURL = [NSURL URLWithString:[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey]];
        image = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
    }
    
    if (image != nil)
        return [[GADNativeAdImage alloc] initWithImage:image];
    return NULL;
}

- (NSString *)price {
    return NULL;
}

- (NSDecimalNumber *)starRating {
    NSString *rating = [[self.pmNativeAd nativeAssets] objectForKey:kNativeStarRatingKey];
    if (rating == nil)
        return NULL;
    return [NSDecimalNumber decimalNumberWithString:rating];
}

- (NSString *)store {
    return NULL;
}

- (UIView *)adChoicesView {
    return [[self.pmNativeAd nativeAssets] objectForKey:kNativeAdChoicesKey];
}

/// Media view.
- (UIView *)mediaView {
    if ([self.pmNativeAd.providerName isEqualToString:@"adsnative"]) {
        UIView *mediaView = [[UIView alloc] init];
        [self.pmNativeAd loadMediaIntoView:mediaView];
        return mediaView;
    } else {
        return [[self.pmNativeAd nativeAssets] objectForKey:kNativeMediaViewKey];
    }
}

/// Returns YES if the ad has video content.
- (BOOL)hasVideoContent {
    if ([[self.pmNativeAd nativeAssets] objectForKey:kNativeMediaViewKey] != nil)
        return YES;
    return NO;
}

#pragma mark - <GADMediatedNativeAdDelegate>

- (void)mediatedNativeAd:(id<GADMediatedNativeAd>)mediatedNativeAd
         didRenderInView:(UIView *)view
     clickableAssetViews:(NSDictionary<NSString *, UIView *> *)clickableAssetViews
  nonclickableAssetViews:(NSDictionary<NSString *, UIView *> *)nonclickableAssetViews
          viewController:(UIViewController *)viewController {
    
    if([view isKindOfClass:[GADNativeAppInstallAdView class]] && [[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIView class]]) {
        GADNativeAppInstallAdView *v = (GADNativeAppInstallAdView *)view;
        UIView *imageView = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
        imageView.frame = v.iconView.bounds;
        [v.iconView addSubview:imageView];
        [v.iconView bringSubviewToFront:imageView];
    } else if([view isKindOfClass:[GADNativeContentAdView class]] && [[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIView class]]) {
        GADNativeContentAdView *v = (GADNativeContentAdView *)view;
        UIView *imageView = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
        imageView.frame = v.logoView.bounds;
        [v.logoView addSubview:imageView];
        [v.logoView bringSubviewToFront:imageView];
    } else if([view isKindOfClass:[GADUnifiedNativeAd class]] && [[[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey] isKindOfClass:[UIView class]]) {
        GADUnifiedNativeAdView *v = (GADUnifiedNativeAdView *)view;
        UIView *imageView = [[self.pmNativeAd nativeAssets] objectForKey:kNativeIconImageKey];
        imageView.frame = v.iconView.bounds;
        [v.iconView addSubview:imageView];
        [v.iconView bringSubviewToFront:imageView];
    }
    
    [self.pmNativeAd registerNativeAdForView:view];
}

#pragma mark - NSObject
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    if (aProtocol == @protocol(GADMediatedNativeAppInstallAd))
        return self.isAppInstallAd;
    return [super conformsToProtocol:aProtocol];
}


#pragma mark - <AdDelegate>
- (void)anNativeAdDidRecordImpression
{
    [GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordImpression:self];
}

- (BOOL)anNativeAdDidClick:(PMNativeAd *)nativeAd
{
    [GADMediatedNativeAdNotificationSource mediatedNativeAdDidRecordClick:self];
    return NO;
}

- (void)anNativeAdWillLeaveApplication
{
    [GADMediatedNativeAdNotificationSource mediatedNativeAdWillLeaveApplication:self];
}

- (UIViewController *)viewControllerToPresentAdModalView {
    return self.viewController;
}

@end
