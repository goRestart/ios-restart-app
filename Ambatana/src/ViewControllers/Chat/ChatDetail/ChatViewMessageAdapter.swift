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
    
    convenience init() {
        let stickersRepository = Core.stickersRepository
        let myUserRepository = Core.myUserRepository
        self.init(stickersRepository: stickersRepository, myUserRepository: myUserRepository)
    }
    
    init(stickersRepository: StickersRepository, myUserRepository: MyUserRepository) {
        self.stickersRepository = stickersRepository
        self.myUserRepository = myUserRepository
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
        
        let status: ChatMessageStatus = message.isRead ? .read : .sent
        return ChatViewMessage(objectId: message.objectId ,talkerId: message.userId, sentAt: message.createdAt,
                               receivedAt: nil, readAt: nil, type: type, status: status,
                               warningStatus: ChatViewMessageWarningStatus(status: message.warningStatus))
    }
    
    func adapt(_ message: ChatMessage) -> ChatViewMessage {
        
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
        }
        return ChatViewMessage(objectId: message.objectId, talkerId: message.talkerId, sentAt: message.sentAt,
                               receivedAt: message.receivedAt, readAt: message.readAt, type: type,
                               status: message.messageStatus,
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
                secondPhrase.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor, range: range)
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
            secondPhrase.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor, range: range)
        }
        messageSuspiciousMessage.append(secondPhrase)
        return createDisclaimerMessage(messageSuspiciousMessage, showAvatar: false, actionTitle: nil, action: action)
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
