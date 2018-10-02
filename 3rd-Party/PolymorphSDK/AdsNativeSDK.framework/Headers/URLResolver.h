//
//  URLResolver.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 06/10/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLActionInfo.h"

typedef void (^URLResolverCompletionBlock)(URLActionInfo *actionInfo, NSError *error);

@interface URLResolver : NSObject <NSURLConnectionDataDelegate>

+ (instancetype)resolverWithURL:(NSURL *)URL completion:(URLResolverCompletionBlock)completion;
- (void)start;
- (void)cancel;

@end
