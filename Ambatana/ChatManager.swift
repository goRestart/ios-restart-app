//
//  ChatManager.swift
//  LetGo
//
//  Created by Nacho on 26/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

// constants
private let kLetGoChatMessageTypeNormalMessage = 0
private let kLetGoChatMessageTypeOfferMessage = 1
private let kLetGoPushNotificationMaxPayloadSpaceForText = 180

// private singleton instance
private let _singletonInstance = ChatManager()

/** A representation of an LetGo chat conversation with another user */
struct LetGoConversation {
    // conversation object
    let conversationObject: PFObject
    // Extracted metadata about the conversation for performance and utility reasons
    let userAvatarURL: String       // String containing the URL of the image of the user I'm having this conversation with
    var userAvatarImage: UIImage?   // Image from the userAvatarURL
    let userName: String            // name of the user I'm having this conversation with
    let totalMessages: Int          // total number of messages in the conversations.
    let myUnreadMessages: Int       // number of messages I have sent in this conversation
    let otherUnreadMessages: Int    // number of messages the user I'm having this conversation with has sent
    let lastUpdated: NSDate         // date of the last message sent belonging to this conversation.
    let productName: String         // name of the product this conversation's all about
    let amISellingTheProduct: Bool  // Am I selling (user_to = me) or buying (user_from = me) the product this conversation belongs to?
    
    // Generates an LetGoConversation from a PFObject of class "Conversations".
    init(parseConversationObject: PFObject) {
        conversationObject = parseConversationObject
        conversationObject.fetchIfNeeded()

        // distinguish who's the selling/buying user
        let userFrom = conversationObject["user_from"] as? PFUser
        let userTo = conversationObject["user_to"] as? PFUser
        if userFrom?.objectId == PFUser.currentUser()!.objectId { amISellingTheProduct = false } // I am buying/making an offer for this product.
        else { amISellingTheProduct = true }    // I Am selling the product.
        var targetUser: PFUser? = amISellingTheProduct ? userFrom : userTo
        
        // if we have a valid target user, fill the name, and avatar.
        if targetUser != nil {
            targetUser!.fetchIfNeeded()
            if let userAvatarFile = targetUser?["avatar"] as? PFFile { userAvatarURL = userAvatarFile.url! }
            else { userAvatarURL = ""; userAvatarImage = UIImage(named: "no_photo")! }
            userName = targetUser!["username_public"] as? String ?? translate("user")
        } else { // else, put some default values
            userAvatarURL = ""
            userAvatarImage = UIImage(named: "no_photo")!
            userName = translate("user")
        }
        // product object for getting the product name.
        if let productObject = conversationObject["product"] as? PFObject {
            productName = productObject["name"] as? String ?? productObject["description"] as? String ?? translate("product")
        } else { productName = translate("product") }
        
        // initialize conversation values.
        totalMessages = conversationObject["nr_messages"] as? Int ?? 0
        myUnreadMessages = amISellingTheProduct ? conversationObject["nr_msg_to_read_to"] as? Int ?? 0 : conversationObject["nr_messages_to_read_from"] as? Int ?? 0
        otherUnreadMessages = amISellingTheProduct ? conversationObject["nr_msg_to_read_from"] as? Int ?? 0 : conversationObject["nr_messages_to_read_to"] as? Int ?? 0
        lastUpdated = conversationObject.updatedAt!
    }
}

/**
* The LocationManager is in charge of handling the position of the user, updating it conveniently when the user has changed it significantly.
* LocationManager follows the Singleton pattern, so it's accessed by means of the shared method sharedInstance().
*/
class ChatManager: NSObject {
    /** Shared instance */
    class var sharedInstance: ChatManager {
        return _singletonInstance
    }
    
    /** Retrieve all the conversations of a user, including all products, where user_from or user_to matches our currentUser */
    func retrieveMyConversationsWithCompletion(completion: (success: Bool, conversations: [LetGoConversation]?) -> Void) {
        // perform query on conversations.
        let conversationsFrom = PFQuery(className: "Conversations")
        conversationsFrom.whereKey("user_from", equalTo: PFUser.currentUser()!) // I am the user that started the conversation
        let conversationsTo = PFQuery(className: "Conversations")
        conversationsTo.whereKey("user_to", equalTo: PFUser.currentUser()!) // I am the user that received the conversation.
        
        // perform combined query.
        let query = PFQuery.orQueryWithSubqueries([conversationsFrom, conversationsTo])
        query.orderByDescending("updatedAt")
        query.includeKey("product") // make sure we retrieve the product for checking product name.
        query.includeKey("user_to") // if we are the user_from, retrieve the user_to object to get username_public of the other user.
        query.includeKey("user_from") // if we are the user_to, retrieve the user_from object to get username_public of the other user.
        
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if error == nil && results?.count > 0 { // we got some comversations.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let conversations = self.letgoConversationsFromParseObjects(results! as! [PFObject])
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(success: true, conversations: conversations)
                    })
                })
            } else { // error while retrieving conversations.
                completion(success: false, conversations: nil)
            }
        })

    }
    
    /** Retrieves the first conversation found about a concrete product by the currentUser, defining which user to look for the product depending on its ownership, for performance reasons */
    func retrieveMyConversationWithUser(otherUser: PFUser, aboutProduct productObject: PFObject, completion: (success: Bool, conversation: PFObject?) -> Void) {
        // According to the specification, user_from is always the buyer, so if the product belongs to me, I am user_to, else I am user_from
        // supposedly, the product will be in fetched at this point, however, we'll fetch it if needed, just in case.
        // perform query on all conversations, from or two.
        let conversationsFrom = PFQuery(className: "Conversations")
        conversationsFrom.whereKey("user_from", equalTo: PFUser.currentUser()!) // I am the user that started the conversation
        conversationsFrom.whereKey("user_to", equalTo: otherUser)
        conversationsFrom.whereKey("product", equalTo: productObject)
        
        let conversationsTo = PFQuery(className: "Conversations")
        conversationsTo.whereKey("user_from", equalTo: otherUser)
        conversationsTo.whereKey("user_to", equalTo: PFUser.currentUser()!) // I am the user that received the conversation.
        conversationsTo.whereKey("product", equalTo: productObject)

        // perform combined query.
        let query = PFQuery.orQueryWithSubqueries([conversationsFrom, conversationsTo])
        query.includeKey("product")
        query.includeKey("user_to")
        query.includeKey("user_from")

        query.findObjectsInBackgroundWithBlock { (objectsFound, error) -> Void in
            println("My conversations results: \(objectsFound), error = \(error)")
            if objectsFound?.count > 0 {
                dispatch_async(dispatch_get_main_queue(), { completion(success: true, conversation: objectsFound!.first as? PFObject) })
            } else {
                dispatch_async(dispatch_get_main_queue(), { completion(success: false, conversation: nil) })
            }
        }
    }
    
    /** Creates a new conversation with a user about a concrete object */
    func createConversationWithUser(otherUser: PFUser, aboutProduct productObject: PFObject, completion: (success: Bool, conversation: PFObject?) -> Void) {
        let newConversation = PFObject(className: "Conversations")
        newConversation["user_from"] = otherUser // If I create a conversation to buy/make an offer for a product, I am always user_from according to the specification.
        newConversation["user_to"] = PFUser.currentUser() // If I create a conversation to buy/make an offer for a product, the other user is always user_from according to the specification.
        newConversation["product"] = productObject
        newConversation["nr_messages"] = 0
        newConversation["nr_msg_to_read_to"] = 0
        newConversation["nr_msg_to_read_from"] = 0
        newConversation.ACL = globalReadAccessACLWithWritePermissionForUsers([otherUser]) // both participants in the conversation must have write permissions
        
        newConversation.saveInBackgroundWithBlock { (conversationSaved, error) -> Void in
            if conversationSaved { // if we have a new conversation, let's make sure we have everything fetched before returning it.
                newConversation.fetchIfNeededInBackgroundWithBlock({ (fetchedConversation, error) -> Void in
                    if fetchedConversation != nil {
                        dispatch_async(dispatch_get_main_queue(), { completion(success: true, conversation: fetchedConversation!) })
                    } else { dispatch_async(dispatch_get_main_queue(), { completion(success: false, conversation: nil) }) }
                })
            } else { dispatch_async(dispatch_get_main_queue(), { completion(success: false, conversation: nil) }) }
            
        }
    }
    
    /** Processes the conversation PFObjects retrieved from Parse and turn them into valid LetGoConversations, setting the conversations var if successfull */
    func letgoConversationsFromParseObjects(conversationObjects: [PFObject]) -> [LetGoConversation] {
        var conversations: [LetGoConversation] = []
        for conversationObj in conversationObjects {
            conversations.append(LetGoConversation(parseConversationObject: conversationObj))
        }
        return conversations
    }
    
    /** Load messages from conversation */
    func loadMessagesFromConversation(conversation: PFObject, completion: (success: Bool, messages: [PFObject]?) -> Void) {
        let query = PFQuery(className: "Messages")
        query.whereKey("conversation", equalTo: conversation)
        query.includeKey("conversation")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil && results?.count > 0 {
                dispatch_async(dispatch_get_main_queue(), { completion(success: true, messages: results! as? [PFObject]) })
            } else { dispatch_async(dispatch_get_main_queue(), { completion(success: false, messages: nil) }) }
        }
    }
    
    /** Adds a new text message to a conversation object. The message will contain only text (a message string), no media. */
    func addTextMessage(text: String, toUser destinationUser: PFUser, inConversation conversation: PFObject, fromProduct productObject: PFObject, completion: (success: Bool, newlyCreatedMessageObject: PFObject!) -> Void) {
        let newMessage = PFObject(className: "Messages")
        newMessage["conversation"] = conversation
        newMessage["user_from"] = PFUser.currentUser()
        newMessage["user_to"] = destinationUser
        newMessage["is_media"] = false
        newMessage["is_read"] = false
        newMessage["message"] = text
        newMessage["type"] = kLetGoChatMessageTypeNormalMessage
        newMessage["product"] = productObject
        newMessage.ACL = globalReadAccessACL()

        newMessage.saveInBackgroundWithBlock { (saved, savingError) -> Void in
            if saved {
                // Besides, we need to update the conversation values
                // add 1 to total number of messages in conversation
                if let totalMessages = conversation["nr_messages"] as? Int {
                    conversation["nr_messages"] = totalMessages + 1
                }
                // add 1 to the unread messages of my user.
                var fieldToAddOneMoreUnreadMessage = "nr_msg_to_read_from" // let's suppose we are the buyer of the object, not the owner (me = user_from)
                if let fromUserInConversation = conversation["user_from"] as? PFObject {
                    if fromUserInConversation.objectId  == PFUser.currentUser()!.objectId { // if I am actually the owner of the user, not the buyer (me = user_to)
                        fieldToAddOneMoreUnreadMessage = "nr_msg_to_read_to" // change destination field.
                    }
                }
                if let unreadMessages = conversation[fieldToAddOneMoreUnreadMessage] as? Int {
                    conversation[fieldToAddOneMoreUnreadMessage] = unreadMessages + 1
                }
                conversation.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success { conversation.saveEventually(nil) }
                })
                self.sendPushNotificationWithMessage(text, toUser: destinationUser, fromUser: PFUser.currentUser()!, conversationId: conversation.objectId)
                
                // inform the handler of the successfull completion.
                dispatch_async(dispatch_get_main_queue(), { completion(success: true, newlyCreatedMessageObject: newMessage) })
            } else {
                dispatch_async(dispatch_get_main_queue(), { completion(success: false, newlyCreatedMessageObject: nil) })
            }
        }
    }
    
    /** Sends a push notification to a user with a (shortened to max length) text */
    internal func sendPushNotificationWithMessage(message: String, toUser user: PFUser, fromUser sourceUser: PFUser, conversationId: String?) {
        // send a push notification.
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user_objectId", equalTo: user.objectId!)
        let push = PFPush()
        push.setQuery(pushQuery)
        var shortString = (sourceUser["username_public"] as? String ?? translate("message")) + ": " + message
        shortString = count(shortString) > kLetGoPushNotificationMaxPayloadSpaceForText ? shortString.substringToIndex(advance(shortString.startIndex, kLetGoPushNotificationMaxPayloadSpaceForText)) : shortString
        var messageData = ["badge": "Increment", "alert": shortString]
        if conversationId != nil { messageData["c_id"] = conversationId! }
        push.setData(messageData)
        push.sendPushInBackgroundWithBlock { (success, error) -> Void in
            if !success { // try to send again in 1 minute
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(60.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    push.sendPushInBackgroundWithBlock(nil)
                }
            }
        }
        
    }
    
    /** Marks the messages from a user as read in a conversation. */
    func markMessagesAsReadFromUser(user: PFUser, inConversation conversation: PFObject, completion: ((success: Bool) -> Void)?) {
        // define which field to mark as read depending on which interlocutor are we.
        var fieldToAddOneMoreUnreadMessage = "nr_msg_to_read_from" // let's suppose we are the buyer of the object, not the owner (me = user_from)
        if let fromUserInConversation = conversation["user_from"] as? PFObject {
            if fromUserInConversation.objectId  == PFUser.currentUser()!.objectId { // if I am actually the owner of the user, not the buyer (me = user_to)
                fieldToAddOneMoreUnreadMessage = "nr_msg_to_read_to" // change destination field.
            }
        }
        conversation[fieldToAddOneMoreUnreadMessage] = 0
        conversation.saveEventually { (success, error) -> Void in
            if completion != nil { completion!(success: success) }
        }
    }
}











