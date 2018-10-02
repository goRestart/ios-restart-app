//
//  Constants.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 22/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define AN_SDK_VERSION              @"3.2.3"

#define AN_IOS_6_0 60000

#define MINIMUM_REFRESH_INTERVAL            10.0
#define DEFAULT_PMBANNER_REFRESH_INTERVAL     60

enum {
    PM_REQUEST_TYPE_NATIVE = 0,
    PM_REQUEST_TYPE_BANNER = 1,
    PM_REQUEST_TYPE_ALL = 2
};
typedef int PM_REQUEST_TYPE;



extern const CGFloat kStarRatingUniversalScale;
extern const CGFloat kMaxStarRatingValue;
extern const CGFloat kMinStarRatingValue;
extern const NSTimeInterval kDefaultSecondsForImpression;
extern const NSTimeInterval kUpdateCellVisibilityInterval;
extern const NSString *backupClassPrefix;

//Banner Sizes
//320x50
extern CGSize const kPMAdSizeMobileLeaderboard;
//300x50
extern CGSize const kPMAdSizeSmallMobileLeaderboard;
//300x250
extern CGSize const kPMAdSizeMediumRect;
//728x90
extern CGSize const kPMAdSizeLeaderboard;
//970x250
extern CGSize const kPMAdSizeBillboard;
//160x600
extern CGSize const kPMAdSizeWideSkyscraper;
//120x600
extern CGSize const kPMAdSizeSkyscraper;
//300x100
extern CGSize const kPMAdSizeRectangle;
//300x600
extern CGSize const kPMAdSizeHalfPage;
//400x300
extern CGSize const kPMAdSizeMining;
