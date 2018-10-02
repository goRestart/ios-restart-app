//
//  URLActionInfo.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 06/10/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(NSUInteger, URLActionType) {
    URLActionTypeStoreKit,
    URLActionTypeOpenInWebView,
    URLActionTypeOpenInSafari
};

@interface URLActionInfo : NSObject

@property (nonatomic, readonly) URLActionType actionType;
@property (nonatomic, readonly, copy) NSURL *originalURL;
@property (nonatomic, readonly, copy) NSString *iTunesItemIdentifier;
@property (nonatomic, readonly, copy) NSURL *iTunesStoreFallbackURL;
@property (nonatomic, readonly, copy) NSURL *safariDestinationURL;
@property (nonatomic, readonly, copy) NSString *HTTPResponseString;
@property (nonatomic, readonly, copy) NSURL *webViewBaseURL;

+ (instancetype)infoWithURL:(NSURL *)URL iTunesItemIdentifier:(NSString *)identifier iTunesStoreFallbackURL:(NSURL *)URL;
+ (instancetype)infoWithURL:(NSURL *)URL safariDestinationURL:(NSURL *)safariDestinationURL;

+ (instancetype)infoWithURL:(NSURL *)URL HTTPResponseString:(NSString *)responseString webViewBaseURL:(NSURL *)baseURL;

@end
