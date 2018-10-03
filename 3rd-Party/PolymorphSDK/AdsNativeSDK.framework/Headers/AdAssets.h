//
//  AdAssets.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 17/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/** Native Asset Keys */
extern const NSString *kNativeTitleKey;
extern const NSString *kNativeTextKey;
extern const NSString *kNativeIconImageKey;
extern const NSString *kNativeMainImageKey;
extern const NSString *kNativeCTATextKey;
extern const NSString *kNativeStarRatingKey;

/* Banner Key */
extern const NSString *kEmbedUrlKey;
extern const NSString *kHtmlKey;

/* Contains the view containing ad choices icon for third party sdk networks */
extern const NSString *kNativeAdChoicesKey;

//May be nil. Contains the media view if ad returned is a video ad for third party sdk networks.
//Will contain a view renderer object for direct sold ads. Must call `loadMediaIntoView:` for direct sold
//ads to render videos.
extern const NSString *kNativeMediaViewKey;

//The Tag to be attached to `kNativeSponsoredKey` Eg: 'By advertiser'
extern const NSString *kNativeSponsoredKey;

//Eg: "Sponsored", "Promoted"
extern const NSString *kNativeSponsoredByTagKey;

//Privacy link. May be empty
extern const NSString *kNativePrivacyLink;
extern const NSString *kNativePrivacyImageUrl;

//May be nil. This returns a dictionary of developer defined custom assests.
extern const NSString *kNativeCustomAssetsKey;

extern const NSString *kNativeBackUpRequiredKey;
extern const NSString *kNativeSDKConfigsKey;

extern const NSString *kNativeAdTypeKey;
extern const NSString *kNativeEcpmKey;

//Media View Assets
//May be nil if not a media ad
extern const NSString *kNativeVideoSourcesKey;
extern const NSString *kNativeVideoExperienceKey;
extern const NSString *kNativeVideoEmbedTypeKey;
//Media View Trackers
extern const NSString *kNativeVideoImpressionTrackerKey;
extern const NSString *kNativeVideoPercentageTrackerKey;
extern const NSString *kNativeVideoCompletionTrackerKey;
extern const NSString *kNativeVideoClickThroughTrackerKey;
extern const NSString *kNativeVideoPlayTrackerKey;

//Trackers and landing url
extern const NSString *kNativeImpressionsKey;
extern const NSString *kNativeClicksKey;
extern const NSString *kNativeLandingUrlKey;

//May be nil. This returns a dictionary of publisher defined custom actions.
extern const NSString *kNativeCustomActionsKey;
