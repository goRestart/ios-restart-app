//
//  KAHEventBuilder.h
//  KahunaSDK
//
//  Copyright (c) 2012-2015 Kahuna. All rights reserved.
//
//

#import <Foundation/Foundation.h>

@class KAHEvent;

@interface KAHEventBuilder : NSObject {
    NSString *_name;
    NSMutableDictionary *_properties;
    long _purchaseCount;
    long _purchaseValue;
}

+ (KAHEventBuilder*) eventWithName:(NSString*) name;
- (KAHEventBuilder*) setPurchaseCount:(long) count andPurchaseValue:(long) value;

// NOTE : Please check with your CS representative before you use the Intelligent Events API.
- (KAHEventBuilder*) addProperty:(NSString*)key withValue:(NSString*)value;
- (KAHEvent*) build;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary *properties;
@property(nonatomic, readonly) long purchaseCount;
@property(nonatomic, readonly) long purchaseValue;

@end
