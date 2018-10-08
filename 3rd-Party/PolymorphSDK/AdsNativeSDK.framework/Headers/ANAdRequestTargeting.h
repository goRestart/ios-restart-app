//
//  ANAdRequestTargeting.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 23/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 * The `ANAdRequestTargeting` class is used to attach targeting information to
 * `AdRequest` objects.
 */
@interface ANAdRequestTargeting : NSObject

/** @name Creating a Targeting Object */

/**
 * Creates and returns an empty ANAdRequestTargeting object.
 *
 * @return A newly initialized ANAdRequestTargeting object.
 */
+ (ANAdRequestTargeting *)targeting;

/** @name Targeting Parameters */

/**
 * A string representing a set of keywords that should be passed to the AdsNative ad server to receive
 * more relevant advertising.
 *
 * Keywords are typically used to target ad campaigns at specific user segments. They should be
 * formatted as an array of strings (e.g. of keywords -"social","music").
 *
 */
@property (nonatomic, copy) NSArray *keywords;

/**
 * A `CLLocation` object representing a user's location that should be passed to the AdsNative ad server
 * to receive more relevant advertising.
 */
@property (nonatomic, copy) CLLocation *location;


@end
