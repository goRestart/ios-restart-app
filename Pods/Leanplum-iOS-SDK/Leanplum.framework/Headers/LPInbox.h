//
//  LPInbox.h
//  Leanplum
//
//  Created by Aleksandar Gyorev on 05/08/15.
//  Copyright (c) 2015 Leanplum. All rights reserved.
//
//

#import <Foundation/Foundation.h>

#pragma mark - LPInboxMessage interface

@interface LPInboxMessage : NSObject <NSCoding>

#pragma mark - LPInboxMessage methods

/**
 * Returns the message identifier of the inbox message.
 */
- (NSString *)messageId;

/**
 * Returns the title of the inbox message.
 */
- (NSString *)title;

/**
 * Returns the subtitle of the inbox message.
 */
- (NSString *)subtitle;

/**
 * Returns the delivery timestamp of the inbox message.
 */
- (NSDate *)deliveryTimestamp;

/**
 * Return the expiration timestamp of the inbox message.
 */
- (NSDate *)expirationTimestamp;

/**
 * Returns YES if the inbox message is read.
 */
- (BOOL)isRead;

/**
 * Read the inbox message, marking it as read and invoking its open action.
 */
- (void)read;

/**
 * Remove the inbox message from the inbox.
 */
- (void)remove;

@end

#pragma mark - LPInbox interface

/**
 * This block is used when you define a callback.
 */
typedef void (^LeanplumInboxChangedBlock)();

@interface LPInbox : NSObject

#pragma mark - LPInbox methods

/**
 * Returns the number of all inbox messages on the device.
 */
- (NSUInteger)count;

/**
 * Returns the number of the unread inbox messages on the device.
 */
- (NSUInteger)unreadCount;

/**
 * Returns the identifiers of all inbox messages on the device sorted in ascending
 * chronological order, i.e. the id of the oldest message is the first one, and the most
 * recent one is the last one in the array.
 */
- (NSArray *)messagesIds;

/**
 * Returns an array containing all of the inbox messages (as LPInboxMessage objects)
 * on the device, sorted in ascending chronological order, i.e. the oldest message is the 
 * first one, and the most recent one is the last one in the array.
 */
- (NSArray *)allMessages;

/**
 * Returns an array containing all of the unread inbox messages on the device, sorted
 * in ascending chronological order, i.e. the oldest message is the first one, and the
 * most recent one is the last one in the array.
 */
- (NSArray *)unreadMessages;

/**
 * Returns the inbox messages associated with the given messageId identifier.
 */
- (LPInboxMessage *)messageForId:(NSString *)messageId;

/**
 * Block to call when the inbox receive new values from the server.
 * This will be called on start, and also later on if the user is in an experiment
 * that can update in realtime.
 */
- (void)onChanged:(LeanplumInboxChangedBlock)block;

/**
 @{
 * Adds a responder to be executed when an event happens.
 * Uses NSInvocation instead of blocks.
 * @see [Leanplum onStartResponse:]
 */
- (void)addInboxChangedResponder:(id)responder withSelector:(SEL)selector;
- (void)removeInboxChangedResponder:(id)responder withSelector:(SEL)selector;
/**@}*/

@end

#pragma mark - LPNewsfeed for backwards compatibility
@interface LPNewsfeedMessage : LPInboxMessage

@end

typedef void (^LeanplumNewsfeedChangedBlock)();

@interface LPNewsfeed : NSObject

+ (LPNewsfeed *)sharedState;
- (NSUInteger)count;
- (NSUInteger)unreadCount;
- (NSArray *)messagesIds;
- (NSArray *)allMessages;
- (NSArray *)unreadMessages;
- (void)onChanged:(LeanplumNewsfeedChangedBlock)block;
- (LPNewsfeedMessage *)messageForId:(NSString *)messageId;
- (void)addNewsfeedChangedResponder:(id)responder withSelector:(SEL)selector __attribute__((deprecated));
- (void)removeNewsfeedChangedResponder:(id)responder withSelector:(SEL)selector __attribute__((deprecated));

@end
