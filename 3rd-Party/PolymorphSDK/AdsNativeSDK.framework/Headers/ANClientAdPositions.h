//
//  ANClientAdPositions.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 16/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import "ANAdPositions.h"

@interface ANClientAdPositions : ANAdPositions

+ (instancetype)positioning;

- (void)addFixedIndexPath:(NSIndexPath *)indexPath;

- (void)enableRepeatingPositionsWithInterval:(NSUInteger)interval;

@end
