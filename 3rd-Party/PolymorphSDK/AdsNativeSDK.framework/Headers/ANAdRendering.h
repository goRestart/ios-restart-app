//
//  ANAdRendering.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 22/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import "PMNativeAd.h"

/**
 * The ANAdRendering protocol provides methods for displaying ad content in
 * custom view classes.
 */

@protocol ANAdRendering <NSObject>

/**
 * Populates a view's relevant subviews with ad content.
 *
 * Your implementation of this method should call one or more of the methods listed below.
 *
 * @param adObject An object containing ad assets (text, images) which may be loaded
 * into appropriate subviews (UILabel, UIImageView) via convenience methods.
 * @see [NativeAd loadTextIntoLabel:]
 * @see [NativeAd loadTitleIntoLabel:]
 * @see [NativeAd loadIconIntoImageView:]
 * @see [NativeAd loadImageIntoImageView:]
 * @see [NativeAd loadCallToActionTextIntoLabel:]
 * @see [NativeAd loadCallToActionTextIntoButton:]
 * @see [NativeAd loadImageForURL:intoImageView:]
 */
- (void)layoutAdAssets:(PMNativeAd *)adObject;

@optional

/**
 * Returns size of the rendering object given a maximum width.
 *
 * @param maximumWidth The maximum width intended for the size of the view.
 *
 * @return a CGSize that corresponds to the given maximumWidth.
 */
+ (CGSize)sizeWithMaximumWidth:(CGFloat)maximumWidth;

/**
 * Specifies a nib object containing a view that should be used to render ads.
 *
 * If you want to use a nib object to render ads, you must implement this method.
 *
 * @return an NSString object which will used to initialize UINib object. This is not allowed to be `nil`.
 */
+ (NSString *)nibForAd;
@end
