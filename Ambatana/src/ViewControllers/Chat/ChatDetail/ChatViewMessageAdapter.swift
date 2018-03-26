//
//  ChatViewMessageAdapter.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ChatViewMessageAdapter {
    let stickersRepository: StickersRepository
    let myUserRepository: MyUserRepository
    let featureFlags: FeatureFlaggeable
    let meetingParser: MeetingParser
    
    convenience init() {
        let stickersRepository = Core.stickersRepository
        let myUserRepository = Core.myUserRepository
        let featureFlags = FeatureFlags.sharedInstance
        let meetingParser = MeetingParser.sharedInstance
        self.init(stickersRepository: stickersRepository, myUserRepository: myUserRepository, featureFlags: featureFlags,
                  meetingParser: meetingParser)
    }
    
    init(stickersRepository: StickersRepository, myUserRepository: MyUserRepository, featureFlags: FeatureFlaggeable,
         meetingParser: MeetingParser) {
        self.stickersRepository = stickersRepository
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
        self.meetingParser = meetingParser
    }
    
    func adapt(_ message: Message) -> ChatViewMessage {
        
        let type: ChatViewMessageType
        switch message.type {
        case .offer:
            type = ChatViewMessageType.offer(text: message.text)
        case .text:
            type = ChatViewMessageType.text(text: message.text)
        case .sticker:
            if let sticker = stickersRepository.sticker(message.text) {
                type = ChatViewMessageType.sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.text(text: message.text)
            }
        }
        
        let status: ChatMessageStatus = message.isRead ? .read : .unknown
        return ChatViewMessage(objectId: message.objectId, talkerId: message.userId, sentAt: message.createdAt,
                               receivedAt: nil, readAt: nil, type: type, status: status,
                               warningStatus: ChatViewMessageWarningStatus(status: message.warningStatus))
    }
    
    func adapt(_ message: ChatMessage) -> ChatViewMessage? {
        
        let type: ChatViewMessageType
        switch message.type {
        case .offer:
            type = ChatViewMessageType.offer(text: message.text)
        case .text, .quickAnswer, .expressChat, .favoritedListing:
            type = ChatViewMessageType.text(text: message.text)
        case .sticker:
            if let sticker = stickersRepository.sticker(message.text) {
                type = ChatViewMessageType.sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.text(text: message.text)
            }
        case .phone:
            type = ChatViewMessageType.text(text: LGLocalizedString.professionalDealerAskPhoneChatMessage(message.text))
        case .chatNorris:
            if featureFlags.chatNorris.isActive,
                let meeting = meetingParser.createMeetingFromMessage(message: message.text) {
                if meeting.meetingType == .requested {
                    type = ChatViewMessageType.chatNorris(type: meeting.meetingType,
                                                          date: meeting.date,
                                                          locationName: meeting.locationName,
                                                          coordinates: meeting.coordinates,
                                                          status: meeting.status,
                                                          text: message.text)
                } else {
                    return nil
                }
            } else {
                type = ChatViewMessageType.text(text: message.text)
            }
        case .interlocutorIsTyping:
            type = ChatViewMessageType.interlocutorIsTyping
        }
        return ChatViewMessage(objectId: message.objectId, talkerId: message.talkerId, sentAt: message.sentAt,
                               receivedAt: message.receivedAt, readAt: message.readAt, type: type,
                               status: message.messageStatus,
                               warningStatus: ChatViewMessageWarningStatus(status: message.warnings))
    }
    
    func adapt(_ message: ChatInactiveMessage) -> ChatViewMessage {
        let type: ChatViewMessageType
        let text = message.content.text ?? ""
        switch message.content.type {
        case .offer:
            type = ChatViewMessageType.offer(text: text)
        case .text, .quickAnswer, .expressChat, .favoritedListing:
            type = ChatViewMessageType.text(text: text)
        case .sticker:
            if let sticker = stickersRepository.sticker(text) {
                type = ChatViewMessageType.sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.text(text: text)
            }
        case .phone:
            type = ChatViewMessageType.text(text: LGLocalizedString.professionalDealerAskPhoneChatMessage(text))
        case .chatNorris:
            if let meeting = meetingParser.createMeetingFromMessage(message: text) {
                type = ChatViewMessageType.chatNorris(type: meeting.meetingType,
                                                      date: meeting.date,
                                                      locationName: meeting.locationName,
                                                      coordinates: meeting.coordinates,
                                                      status: meeting.status,
                                                      text: text)
            } else {
                type = ChatViewMessageType.text(text: text)
            }
        case .interlocutorIsTyping:
            type = ChatViewMessageType.interlocutorIsTyping
        }
        return ChatViewMessage(objectId: message.objectId,
                               talkerId: message.talkerId,
                               sentAt: message.sentAt,
                               receivedAt: nil,
                               readAt: nil,
                               type: type,
                               status: nil,
                               warningStatus: ChatViewMessageWarningStatus(status: message.warnings))
    }
    
    func addDisclaimers(_ messages: [ChatViewMessage], disclaimerMessage: ChatViewMessage) -> [ChatViewMessage] {
        return messages.reduce([ChatViewMessage]()) { [weak self] (array, message) -> [ChatViewMessage] in
            if message.warningStatus == .spam && message.talkerId != self?.myUserRepository.myUser?.objectId {
                return array + [disclaimerMessage] + [message]
            }
            return array + [message]
        }
    }

    func createScammerDisclaimerMessage(isBuyer: Bool, userName: String?, action: (() -> ())?) -> ChatViewMessage {
        let chatBlockedMessage =  ChatViewMessageAdapter.alertMutableAttributedString

        let message: NSAttributedString
        if isBuyer {
            if let otherUserName = userName {
                message = NSAttributedString(string: LGLocalizedString.chatForbiddenDisclaimerBuyerWName(otherUserName))
            } else {
                message = NSAttributedString(string: LGLocalizedString.chatForbiddenDisclaimerBuyerWoName)
            }
            chatBlockedMessage.append(message)
            chatBlockedMessage.append(NSAttributedString(string: " "))
            let keyword = LGLocalizedString.chatBlockedDisclaimerScammerAppendSafetyTipsKeyword
            let secondPhraseStr = LGLocalizedString.chatBlockedDisclaimerScammerAppendSafetyTips(keyword)
            let secondPhraseNSStr = NSString(string: secondPhraseStr)
            let range = secondPhraseNSStr.range(of: keyword)

            let secondPhrase = NSMutableAttributedString(string: secondPhraseStr)
            if range.location != NSNotFound {
                secondPhrase.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.primaryColor, range: range)
            }
            chatBlockedMessage.append(secondPhrase)
        } else {
            if let otherUserName = userName {
                message = NSAttributedString(string: LGLocalizedString.chatForbiddenDisclaimerSellerWName(otherUserName))
            } else {
                message = NSAttributedString(string: LGLocalizedString.chatForbiddenDisclaimerSellerWoName)
            }
            chatBlockedMessage.append(message)
        }

        return createDisclaimerMessage(chatBlockedMessage, showAvatar: true, actionTitle: nil, action: action)
    }

    func createUserDeletedDisclaimerMessage(_ userName: String?) -> ChatViewMessage {
        let chatDeletedMessage = ChatViewMessageAdapter.alertMutableAttributedString
        let message: String
        if let otherUserName = userName {
            message = LGLocalizedString.chatDeletedDisclaimerWName(otherUserName)
        } else {
            message = LGLocalizedString.chatDeletedDisclaimerWoName
        }
        chatDeletedMessage.append(NSAttributedString(string: message))
        return createDisclaimerMessage(chatDeletedMessage, showAvatar: true, actionTitle: nil, action: nil)
    }

    func createMessageSuspiciousDisclaimerMessage(_ action: (() -> ())?) -> ChatViewMessage {
        let messageSuspiciousMessage = ChatViewMessageAdapter.alertMutableAttributedString
        var keyword = ""
        if let _ = action {
             keyword = LGLocalizedString.chatMessageDisclaimerScammerAppendBlocked
        }
        let secondPhraseStr = LGLocalizedString.chatMessageDisclaimerScammerBaseBlocked(keyword)
        let secondPhraseNSStr = NSString(string: secondPhraseStr)
        let range = secondPhraseNSStr.range(of: keyword)

        let secondPhrase = NSMutableAttributedString(string: secondPhraseStr)
        if range.location != NSNotFound {
            secondPhrase.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.primaryColor, range: range)
        }
        messageSuspiciousMessage.append(secondPhrase)
        return createDisclaimerMessage(messageSuspiciousMessage, showAvatar: false, actionTitle: nil, action: action)
    }
    
    func createSecurityMeetingDisclaimerMessage() -> ChatViewMessage {
        let message = ChatViewMessageAdapter.alertMutableAttributedString
        message.append(NSAttributedString(string: LGLocalizedString.chatMessageDisclaimerMeetingSecurity))
        return createDisclaimerMessage(message, showAvatar: false, actionTitle: nil, action: nil)
    }

    func createUserInfoMessage(_ user: User?) -> ChatViewMessage? {
        guard let user = user else { return nil }
        let facebook = user.facebookAccount?.verified ?? false
        let google = user.googleAccount?.verified ?? false
        let email = user.emailAccount?.verified ?? false
        let name = LGLocalizedString.chatUserInfoName(user.name ?? "")
        let address = user.postalAddress.zipCodeCityString
        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                               type: .userInfo(name: name, address: address, facebook: facebook, google: google, email: email),
                               status: nil, warningStatus: .normal)
    }

    func createAskPhoneMessageWith(action: (() -> Void)?) -> ChatViewMessage? {

        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: Date(), receivedAt: nil, readAt: nil,
                               type: .askPhoneNumber(text: LGLocalizedString.professionalDealerAskPhoneAddPhoneCellMessage,
                                                     action: action),
                               status: nil, warningStatus: .normal)
    }

    func createAutomaticAnswerWith(message: String) -> ChatViewMessage? {
        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: Date(), receivedAt: nil, readAt: nil,
                               type: .text(text: message), status: nil, warningStatus: .normal)
    }

    func createInterlocutorIsTyping() -> ChatViewMessage {
        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                               type: .interlocutorIsTyping, status: nil, warningStatus: .normal)
    }
    
    private func createDisclaimerMessage(_ disclaimerText: NSAttributedString, showAvatar: Bool, actionTitle: String?,
                                         action: (() -> ())?) -> ChatViewMessage {
        let disclaimer = ChatViewMessageType.disclaimer(showAvatar: showAvatar, text: disclaimerText,
                                                        actionTitle: actionTitle, action: action)
        let disclaimerMessage = ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                                                type: disclaimer, status: nil, warningStatus: .normal)
        return disclaimerMessage
    }

    private static var alertMutableAttributedString: NSMutableAttributedString {
        let icon = NSTextAttachment()
        icon.image = UIImage(named: "ic_alert_gray")
        let iconString = NSAttributedString(attachment: icon)
        let alertString = NSMutableAttributedString(attributedString: iconString)
        alertString.append(NSAttributedString(string: " "))
        return alertString
    }
}
