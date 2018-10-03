//
//  ANAVFullScreenPlayerViewController.h
//
//  Created by Arvind Bharadwaj on 15/12/15.
//  Copyright © 2015 AdsNative. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANPlayerViewController;
@class ANPlayerView;
@class ANAVFullscreenPlayerViewController;

@protocol ANAVFullscreenPlayerViewControllerDelegate <NSObject>

- (void)playerDidProgressToTime:(NSTimeInterval)playbackTime totalTime:(NSTimeInterval)totalTime;

@end

typedef void (^ANAVFullScreenPlayerViewControllerDismissBlock)(UIView *originalParentView);

@interface ANAVFullScreenPlayerViewController : UIViewController

@property (nonatomic) ANPlayerView *playerView;
@property (nonatomic) BOOL isPresented;

@property (nonatomic, weak) id<ANAVFullscreenPlayerViewControllerDelegate> delegate;

- (instancetype)initWithVideoPlayer:(ANPlayerViewController *)playerController nativeAssets:(NSDictionary *)nativeAssets dismissBlock:(ANAVFullScreenPlayerViewControllerDismissBlock)dismiss;

- (void)dispose;
@end
