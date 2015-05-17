//
//  UIView+Appereance.h
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

#import <UIKit/UIKit.h>

// http://stackoverflow.com/questions/24136874/appearancewhencontainedin-in-swift

@interface UIView (Appereance)

+ (instancetype)lg_appearanceWhenContainedWithin:(NSArray *)containers;

@end
