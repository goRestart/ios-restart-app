//
//  KahunaInAppMessage.m
//  HowToUseKahuna
//
//  Copyright (c) 2014 Kahuna. All rights reserved.
//

#import "KahunaInAppMessageView.h"

@implementation KahunaInAppMessageView

- (id)initToShow:(ShowWhere)_where onView:(UIView*)onView withMessage:(NSString*)message withImage:(NSData*) imageData withDeepLink:(NSDictionary*)deepLink
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect inAppMessageBounds;
    if (InAppMessageViewUseEntireScreenToComputePosition) {
        inAppMessageBounds = screenFrame;
    } else {
        inAppMessageBounds = appFrame;
    }
    CGRect inAppMessageFrame;
#if !__has_feature(objc_arc)
    parentView = [onView retain];
#else
    parentView = onView;
#endif
    
    switch (_where)
    {
        case OnTop: {
            int width = InAppMessageViewWidth==INT_MAX?inAppMessageBounds.size.width- 2*InAppMessageViewExternalPadding:InAppMessageViewWidth;
            int height = InAppMessageViewHeight==INT_MAX?inAppMessageBounds.size.height:InAppMessageViewHeight;
            int x = (inAppMessageBounds.size.width - width) / 2;
            if (x < 0) x = 0;
            if (width >= inAppMessageBounds.size.width) width = inAppMessageBounds.size.width - 2*InAppMessageViewExternalPadding;
            if (height >= inAppMessageBounds.size.height) height = inAppMessageBounds.size.height;
            
            inAppMessageFrame = CGRectMake(x,
                                           inAppMessageBounds.origin.y + InAppMessageViewExternalPadding,
                                           width,
                                           height);
            break;
        }
        case InCenter: {
            int width = InAppMessageViewWidth==INT_MAX?inAppMessageBounds.size.width - 2*InAppMessageViewExternalPadding:InAppMessageViewWidth;
            int height = InAppMessageViewHeight==INT_MAX?inAppMessageBounds.size.height:InAppMessageViewHeight;
            int x = (inAppMessageBounds.size.width - width) / 2;
            if (x < inAppMessageBounds.origin.x || x >= inAppMessageBounds.size.width) x = inAppMessageBounds.origin.x;
            int y = (inAppMessageBounds.size.height - (InAppMessageViewHeight==INT_MAX?inAppMessageBounds.size.height:InAppMessageViewHeight)) / 2;
            if (y < inAppMessageBounds.origin.y || y >= inAppMessageBounds.size.height) y = inAppMessageBounds.origin.y;
            if (width >= inAppMessageBounds.size.width) width = inAppMessageBounds.size.width - 2*InAppMessageViewExternalPadding;
            if (height >= inAppMessageBounds.size.height) height = inAppMessageBounds.size.height - 2*InAppMessageViewExternalPadding;
            
            inAppMessageFrame = CGRectMake(x, y, width, height);
            break;
        }
        case OnBottom:{
            int width = InAppMessageViewWidth==INT_MAX?inAppMessageBounds.size.width - 2*InAppMessageViewExternalPadding:InAppMessageViewWidth;
            int height = InAppMessageViewHeight==INT_MAX?inAppMessageBounds.size.height:InAppMessageViewHeight;
            int x = (inAppMessageBounds.size.width - width) / 2;
            if (x < inAppMessageBounds.origin.x || x >= inAppMessageBounds.size.width) x = inAppMessageBounds.origin.x;
            int y = inAppMessageBounds.size.height + inAppMessageBounds.origin.y - (InAppMessageViewHeight==INT_MAX?inAppMessageBounds.size.height:InAppMessageViewHeight);
            if (y < inAppMessageBounds.origin.y || y >= inAppMessageBounds.size.height) y = inAppMessageBounds.origin.y;
            if (width >= inAppMessageBounds.size.width) width = inAppMessageBounds.size.width - 2*InAppMessageViewExternalPadding;
            if (height >= inAppMessageBounds.size.height) height = inAppMessageBounds.size.height;
            
            inAppMessageFrame = CGRectMake(x, y, width, height);
            break;
        }
        default:{
            break;
        }
    }
    
    self = [super initWithFrame:inAppMessageFrame];
    if (self) {
        self.tag = 9999;
        self.backgroundColor = InAppMessageViewBackgroundColor;
        if (InAppMessageViewRoundedEdges) {
            self.layer.cornerRadius = 2; // this value vary as per your desire
        }
        self.clipsToBounds = YES;
        
        int messageX = InAppMessageViewInternalPadding;
        int messageY = InAppMessageViewInternalPadding;
        
        // If we have a deep linked image add it.
        if (imageData) {
            CGRect imageFrame = CGRectMake(InAppMessageViewInternalPadding, InAppMessageViewInternalPadding, InAppMessageImageWidth, InAppMessageImageHeight);
            UIImageView *kahunaInAppMessageImageView = [[UIImageView alloc] initWithFrame:imageFrame];
            kahunaInAppMessageImageView.contentMode = UIViewContentModeScaleAspectFit;
            kahunaInAppMessageImageView.image = [UIImage imageWithData:imageData];
            [self addSubview:kahunaInAppMessageImageView];
            if (InAppMessageImageRoundedEdges) {
                kahunaInAppMessageImageView.layer.cornerRadius = 5; // this value vary as per your desire
            }
            kahunaInAppMessageImageView.clipsToBounds = YES;
#if !__has_feature(objc_arc)
            [kahunaInAppMessageImageView release];
#else
            kahunaInAppMessageImageView = nil;
#endif
            messageX = imageFrame.origin.x + imageFrame.size.width + InAppMessageViewInternalPadding;
        }
        
        // Now add the message.
        CGRect messageFrame = CGRectMake(messageX,
                                         messageY,
                                         inAppMessageFrame.size.width - messageX - InAppMessageViewInternalPadding - InAppMessageGoButtonWidth,
                                         inAppMessageFrame.size.height - InAppMessageViewInternalPadding);
        UILabel *kahunaInAppMessage = [[UILabel alloc] initWithFrame:messageFrame];
        kahunaInAppMessage.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", InAppMessageFont] size:InAppMessageTextFontSize];
        kahunaInAppMessage.textColor = InAppMessageMessageColor;
        kahunaInAppMessage.backgroundColor = [UIColor clearColor];
        kahunaInAppMessage.text = message;
        kahunaInAppMessage.numberOfLines = 3;
        [kahunaInAppMessage sizeToFit];
        [self addSubview:kahunaInAppMessage];
#if !__has_feature(objc_arc)
        [kahunaInAppMessage release];
#else
        kahunaInAppMessage = nil;
#endif
        
        // Now add a tap to dismiss button on top right.
        CGRect tapToDismissFrame = CGRectMake(inAppMessageFrame.size.width - InAppMessageXButtonWidth - InAppMessageViewInternalPadding, InAppMessageViewInternalPadding, InAppMessageXButtonWidth, InAppMessageXButtonHeight);
        UIButton *tapToDismiss = [[UIButton alloc] initWithFrame:tapToDismissFrame];
        tapToDismiss.backgroundColor = [UIColor clearColor];
        tapToDismiss.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", InAppMessageFont] size:InAppMessageXButtonFontSize];
        [tapToDismiss setTitle:@"⊗" forState:UIControlStateNormal];
        [tapToDismiss setTitleColor:InAppMessageXButtonColor forState:UIControlStateNormal];
        [tapToDismiss addTarget:self action:@selector(tapToDismissClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tapToDismiss];
        
        // This will clear existing InApp messages being shown.
        [self tapToDismissClicked:tapToDismiss];
        if (InAppMessageViewAutoDismissInSeconds > 0 && InAppMessageViewAutoDismissInSeconds != INT_MAX) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(InAppMessageViewAutoDismissInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self tapToDismissClicked:tapToDismiss];
            });
        }
#if !__has_feature(objc_arc)
        [tapToDismiss release];
#else
        tapToDismiss = nil;
#endif
        // Now add a Go button. This is only turned on if there are deep link params associated with the message.
        if (deepLink != nil && [deepLink count] > 0) {
#if !__has_feature(objc_arc)
            deepLinkParams = [deepLink retain];
#else
            deepLinkParams = deepLink;
#endif
            CGRect goFrame = CGRectMake(inAppMessageFrame.size.width - InAppMessageGoButtonWidth - InAppMessageViewInternalPadding, inAppMessageFrame.size.height - InAppMessageGoButtonHeight - InAppMessageViewInternalPadding, InAppMessageGoButtonWidth, InAppMessageGoButtonHeight);
            UIButton *btnGo = [[UIButton alloc] initWithFrame:goFrame];
            btnGo.backgroundColor = InAppMessageGoButtonBackgroundColor;
            btnGo.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", InAppMessageFont] size:InAppMessageGoButtonTextFontSize];
            [btnGo setTitle:InAppMessageDeepLinkButtonText forState:UIControlStateNormal];
            [btnGo setTitleColor:InAppMessageGoButtonTextColor forState:UIControlStateNormal];
            [btnGo addTarget:self action:@selector(goClicked:) forControlEvents:UIControlEventTouchUpInside];
            btnGo.layer.cornerRadius = 5; // this value vary as per your desire
            btnGo.clipsToBounds = YES;
            [self addSubview:btnGo];
#if !__has_feature(objc_arc)
            [btnGo release];
#else
            btnGo = nil;
#endif
        }
        
        if (InAppMessageDimBackground) {
            // Add a dim background on the whole screen.
            UIView *dimBackground = [[UIView alloc] initWithFrame:screenFrame];
            dimBackground.backgroundColor = InAppMessageDimBackgroundColor;
            dimBackground.tag = 9998;
            
            // Add the dim background.
            [parentView addSubview:dimBackground];
#if !__has_feature(objc_arc)
            [dimBackground release];
#else
            dimBackground = nil;
#endif
        }
        
        // Now add the in app message view on top of the window. You can put this view any place you wish.
        [parentView addSubview:self];
        
        // If we need animation, setup the animation.
        if (InAppMessageAnimateAppearance) {
            
            CGRect originalInAppMessageFrame = self.frame;
            CGRect copyInAppMessageFrame = originalInAppMessageFrame;
            
            switch (_where)
            {
                case OnTop: {
                    copyInAppMessageFrame.origin.y = -2 * InAppMessageImageHeight;
                    break;
                }
                case OnBottom: {
                    copyInAppMessageFrame.origin.y = screenFrame.size.height + 2 * InAppMessageImageHeight;
                    break;
                }
                case InCenter: {
                    copyInAppMessageFrame.origin.x = -1 * screenFrame.size.width;
                }
                default:{
                    break;
                }
            }
            
            self.frame = copyInAppMessageFrame;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:InAppMessageAnimationSpeed];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            
            self.frame = originalInAppMessageFrame;
            [UIView commitAnimations];
        }
    }
    return self;
}

- (void) tapToDismissClicked:(id) sender
{
    UIView *dimBackgroundView = [parentView viewWithTag:9998];
    if (dimBackgroundView) [dimBackgroundView removeFromSuperview];
    
    UIView *kahunaInAppMessageView = [parentView viewWithTag:9999];
    if (kahunaInAppMessageView) [kahunaInAppMessageView removeFromSuperview];
}

- (void) goClicked:(id) sender
{
    [self tapToDismissClicked:nil];
    // Use the deep link params [deepLinkParams] to go to a specific part of the app.
}

- (void) dealloc {
#if !__has_feature(objc_arc)
    [deepLinkParams release];
    [super dealloc];
#endif
}

@end
