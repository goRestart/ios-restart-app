//
//  NativeAd.h
//  Polymorph-iOS-SDK
//
//  Created by Arvind Bharadwaj on 22/09/15.
//  Copyright (c) 2015 Polymorph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ANNativeAdDelegate.h"
#import "ANAdRequestTargeting.h"

@protocol AdDelegate;
@protocol AdAdapter;
/**
 * The `PMNativeAd` class is used to render and manage events for a native advertisement. The
 * class provides methods for accessing native ad properties returned by the server, as well as
 * convenience methods for URL navigation and metrics-gathering.
 */

@interface PMNativeAd : NSObject

/** @name Ad Resources */

/**
 * The internal delegate of the `PMNativeAd` object. This is to be used by other classes inside the Polymorph SDK
 */
@property (nonatomic, weak) id<AdDelegate> internalDelegate;

/**
 * The request response delegate of the `PMNativeAd` object. The `ANNativeAdDelegate` protocol has to be implemented
 * for requesting single native ads.
 */
@property (nonatomic,weak) id<ANNativeAdDelegate> delegate;

/*
 * The provider name is the name of the adapter network that the native ad instance was created by.
 * For direct Polymorph ads, this value will be "polymorph", and for s2s ads, it will be "s2s".
 */
@property (nonatomic, strong) NSString *providerName;

#pragma mark - Single Native Ad methods - start
@property (nonatomic, strong) NSString *adUnitID;
@property (nonatomic, strong) Class renderingClass;
@property (nonatomic) float biddingInterval;
/**
 *The methods to be called for requesting a single native ad
 */

/**
 * Initialize the Polymorph SDK with the adUnitId received from the Polymorph UI.
 * @param adUnitId The ad ID received from the Polymorph UI
 */
- (instancetype)initWithAdUnitId:(NSString *)adUnitID;

/**
 * Requests a native ad from the Polymorph ad server using the ad unit ID specified in `initWithAdUnitId`.
 */
- (void)loadAd;


/**
 * Requests a native ad from the Polymorph ad server using the specified ad unit ID (specified in `initWithAdUnitId`) and targeting parameters.
 *
 * @param targeting An object containing targeting information, such as geolocation data.
 * @param requestType can be PM_REQUEST_TYPE_NATIVE or PM_REQUEST_TYPE_ALL. PM_REQUEST_TYPE_ALL is handled internally in PMClass.m
 */
- (void)loadAdWithTargeting:(ANAdRequestTargeting *)targeting requestType:(int)requestType;

/*
 * Creates and returns an ad view where the ad will be displayed. This method should be used specially 
 * when using dynamic layout switching.
 *
 * @param renderingClass The class that will be used to render ads. This class must
 * implement the `ANAdRendering` protocol and must be a subclass of `UIView`.
 * @param the CGRect bounds that this view should render into. May be nil.
 * @return UIView The ad view to be added as a subview of the parent view being passed as param
 */
- (UIView *)renderNativeAdWithDefaultRenderingClass:(Class)renderingClass withBounds:(CGRect)bounds;

/*
 * This method is called to register the to be rendered native ad for impression and click counting. 
 * It is to be called directly by the app developer. The developer calls this method and then renders the individual native ad assets.
 *
 * The developer can get the native assets as a dictionary from the 'nativeAssets' property of this class. The keys for this dictionary
 * are specified in `AdAssets.h`
 *
 * @param adView The view into which the ad sub views will be loaded.
 */
- (void)registerNativeAdForView:(UIView *)adView;

#pragma mark - Single Native Ad methods - end

/**
 * A dictionary representing the native ad properties.
 */
@property (nonatomic, readonly) NSDictionary *nativeAssets;

/**
 * The default click-through URL for the ad.
 *
 * May be nil.
 */
@property (nonatomic, readonly) NSURL *clickThroughURL;

/**
 * The bidding ecpm rounded to the nearest decimal decided by the bidding interval.
 * The bidding interval default is 0.01 and can be modified on the server at an adunit level.
 * returns -1 if no ecpm is returned in the ad response
 */
@property (nonatomic, readonly) float biddingEcpm;
/**
 * Star rating for the ad.
 *
 * This is a float value between 0 and 5.
 *
 * May be nil.
 */
@property (nonatomic, readonly) NSNumber *starRating;

/**
 * A boolean which represents where the ad whether another rendering class should be chosen.
 *
 * The reason a backup would be required is because some ad responses may not contain an icon
 * image url. If that happens, a backup rendering class (which does not define icon image) may be defined
 * to loads native assets into. The backup rendering class should implement the `ANAdRendering` protocol as well.
 *
 * If this is nil or false, then the backup class is not required and assets can be loaded into the main rendering class.
 */
@property (nonatomic, readonly) BOOL isBackupClassRequired;


- (instancetype)initWithAdAdapter:(id<AdAdapter>)adAdapter;

/** @name Preparing Ad Content for Display */

/**
 * Instructs the ad object to configure the provided view with ad content.
 *
 * The provided view should implement the `ANAdRendering` protocol to correctly display the ad
 * content.
 *
 * When this method is called, an impression will automatically be recorded at the appropriate time,
 * so there is no need to additionally invoke -trackImpression.
 *
 * @param view A view that will contain the ad content.
 * @see NativeAdRendering
 */
- (void)prepareForDisplayInView:(UIView *)view;

/** @name Handling Ad Interactions */

/**
 * Records an impression event.
 *
 * When -prepareForDisplayInView is called, -trackImpression will automatically be invoked at the
 * appropriate time, so there is no need to additionally invoke -trackImpression.
 */
- (void)trackImpression;

/**
 * Records a click event.
 *
 * When -displaycontentForURL:rootViewController:completion: is called, a click event will
 * automatically be recorded, so there is no need to additionally invoke -trackClick.
 */
- (void)trackClick;

/**
 * Opens a resource defined by the ad using an appropriate mechanism (typically, an in-application
 * modal web browser or a modal App Store controller).
 *
 * @param completionBlock The block to be executed when the action defined by the URL has been
 * completed, returning control to your application.
 *
 * You should call this method when you detect that a user has tapped on the ad (i.e. via button,
 * table view selection, or gesture recognizer).
 *
 * When this method is called, a click event will automatically be recorded, so there is no
 * need to additionally invoke -trackClick.
 */
- (void)displayContentWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

/**
 * Opens a URL using an appropriate mechanism (typically, an in-application modal web browser or a
 * modal App Store controller).
 *
 * @param URL The URL to be opened.
 * @param completionBlock The block to be executed when the action defined by the URL has been
 * completed, returning control to your application.
 *
 * You should call this method when you detect that a user has tapped on the ad (i.e. via button,
 * table view selection, or gesture recognizer).
 *
 * When this method is called, a click event will automatically be recorded, so there is no
 * need to additionally invoke -trackClick.
 */
- (void)displayContentForURL:(NSURL *)URL completion:(void (^)(BOOL success, NSError *error))completionBlock;

- (void)trackMetricForURL:(NSURL *)URL;

/** @name Loading Specific Ad Resources into Views */
/**
 * Loads a video ad, if available, into the imageView frame location. If video is is not available, it will
 * load the ad objects main image into the imageView passed.
 *
 * @param view The UIView instance to load an image or video into.
 */
- (void)loadMediaIntoView:(UIView *)view;

/**
 * Asynchronously loads the ad object's ad choices icon into the provided image view.
 * This may be nil.
 *
 * @param view A view object.
 */
- (void)loadAdChoicesIconIntoView:(UIView *)view;

/**
 * Asynchronously loads the ad object's icon image into the provided image view.
 *
 * @param imageView An image view.
 */
- (void)loadIconIntoImageView:(UIImageView *)imageView;

/**
 * Asynchronously loads the ad object's main image into the provided image view.
 *
 * @param imageView An image view.
 */
- (void)loadImageIntoImageView:(UIImageView *)imageView;

/**
 * Loads the ad object's Digital Advertising Alliance icon into the provided image view.
 * The SDK takes control of the view. You should not do anything with the view other than
 * position and size it in your native ad view. The SDK will handle all taps on the image view.
 *
 * @param imageView An image view.
 */
- (void)loadSponsoredTagIntoLabel:(UILabel *)label;

/**
 * Loads the ad object's title into the provided label.
 *
 * @param label A label.
 */
- (void)loadTitleIntoLabel:(UILabel *)label;

/**
 * Loads the ad object's main text into the provided label.
 *
 * @param label A label.
 */
- (void)loadTextIntoLabel:(UILabel *)label;

/**
 * Loads the ad object's call-to-action text into the provided label.
 *
 * @param label A label.
 */
- (void)loadCallToActionTextIntoLabel:(UILabel *)label;

/**
 * Loads the ad object's call-to-action text into the provided button.
 *
 * @param button A button.
 */
- (void)loadCallToActionTextIntoButton:(UIButton *)button;

/**
 * Asynchronously loads the image referenced by imageURL into the provided image view.
 *
 * @param imageURL A URL identifying an image resource.
 * @param imageView An image view.
 */
- (void)loadImageForURL:(NSURL *)imageURL intoImageView:(UIImageView *)imageView;
@end
