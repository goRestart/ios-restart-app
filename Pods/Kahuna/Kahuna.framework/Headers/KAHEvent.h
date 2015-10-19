//
//  KAHEvent.h
//  KahunaSDK
//
//  Copyright (c) 2012-2015 Kahuna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KAHNSObject+JSON.h"
#import "KAHEventBuilder.h"

@interface KAHEvent : NSObject <NSCoding>

@property(nonatomic, readonly) NSString * name;

@end
