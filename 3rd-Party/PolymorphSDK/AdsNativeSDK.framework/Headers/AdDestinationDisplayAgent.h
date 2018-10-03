//
//  AdDestinationDisplayAgent.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 06/10/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ANStoreKitProvider.h"

@protocol AdDestinationDisplayAgentDelegate;

@interface AdDestinationDisplayAgent : NSObject <ANSKStoreProductViewControllerDelegate>

@property (nonatomic, weak) id<AdDestinationDisplayAgentDelegate> delegate;

+ (AdDestinationDisplayAgent *)agentWithDelegate:(id<AdDestinationDisplayAgentDelegate>)delegate;
- (void)displayDestinationForURL:(NSURL *)URL;
- (void)cancel;

@end

@protocol AdDestinationDisplayAgentDelegate <NSObject>

- (UIViewController *)viewControllerToPresentModalView;
- (void)displayAgentWillPresentModal;
- (void)displayAgentWillLeaveApplication;
- (void)displayAgentDidDismissModal;

@end