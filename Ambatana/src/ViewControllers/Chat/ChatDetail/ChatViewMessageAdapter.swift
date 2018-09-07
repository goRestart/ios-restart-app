import LGCoreKit
import LGComponents

final class ChatViewMessageAdapter {
    private let stickersRepository: StickersRepository
    private let myUserRepository: MyUserRepository
    private let featureFlags: FeatureFlaggeable
    private let tracker: TrackerProxy

    convenience init() {
        let stickersRepository = Core.stickersRepository
        let myUserRepository = Core.myUserRepository
        let featureFlags = FeatureFlags.sharedInstance
        self.init(stickersRepository: stickersRepository,
                  myUserRepository: myUserRepository,
                  featureFlags: featureFlags,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(stickersRepository: StickersRepository,
         myUserRepository: MyUserRepository,
         featureFlags: FeatureFlaggeable,
         tracker: TrackerProxy) {
        self.stickersRepository = stickersRepository
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
        self.tracker = tracker
    }
    
    func adapt(_ message: Message, userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage {
        
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
                               warningStatus: ChatViewMessageWarningStatus(status: message.warningStatus),
                               userAvatarData: userAvatarData)
    }
    
    func adapt(_ message: ChatMessage, userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage? {
        
        let type: ChatViewMessageType
        let text = message.content.text ?? ""
        switch message.content.type {
        case .offer:
            type = ChatViewMessageType.offer(text: text)
        case .text, .expressChat, .favoritedListing, .interested:
            type = ChatViewMessageType.text(text: text)
        case .quickAnswer(_, let text):
            type = ChatViewMessageType.text(text: text)
        case .sticker:
            if let sticker = stickersRepository.sticker(text) {
                type = ChatViewMessageType.sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.text(text: text)
            }
        case .phone:
            type = ChatViewMessageType.text(text: R.Strings.professionalDealerAskPhoneChatMessage(text))
        case .meeting:
            if featureFlags.chatNorris.isActive, let meeting = message.assistantMeeting {
                if meeting.meetingType == .requested {
                    type = ChatViewMessageType.meeting(type: meeting.meetingType,
                                                       date: meeting.date,
                                                       locationName: meeting.locationName,
                                                       coordinates: meeting.coordinates,
                                                       status: meeting.status,
                                                       text: text)
                } else {
                    return nil
                }
            } else {
                type = ChatViewMessageType.text(text: text)
            }
        case .interlocutorIsTyping:
            type = ChatViewMessageType.interlocutorIsTyping
        case .unsupported(let defaultText):
            type = ChatViewMessageType.unsupported(text: defaultText ?? R.Strings.chatMessageTypeNotSupported)
            tracker.trackEvent(TrackerEvent.chatUpdateAppWarningShow())
        case .multiAnswer(let question, let answers):
            type = ChatViewMessageType.multiAnswer(question: question, answers: answers)
        case .cta(let ctaData, let ctas):
            type = ChatViewMessageType.cta(ctaData: ctaData, ctas: ctas)
        case .carousel:
            type = ChatViewMessageType.unsupported(text: R.Strings.chatMessageTypeNotSupported)
        // ABIOS-4837 waiting for back-end implementation to show this new message type
//        case .carousel(let cards, let answers):
//            type = ChatViewMessageType.carousel(cards: cards, answers: answers)
        }
        return ChatViewMessage(objectId: message.objectId, talkerId: message.talkerId, sentAt: message.sentAt,
                               receivedAt: message.receivedAt, readAt: message.readAt, type: type,
                               status: message.messageStatus,
                               warningStatus: ChatViewMessageWarningStatus(status: message.warnings),
                               userAvatarData: userAvatarData)
    }
    
    func adapt(_ message: ChatInactiveMessage, userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage {
        let type: ChatViewMessageType
        let text = message.content.text ?? ""
        switch message.content.type {
        case .offer:
            type = ChatViewMessageType.offer(text: text)
        case .text, .expressChat, .favoritedListing, .interested:
            type = ChatViewMessageType.text(text: text)
        case .quickAnswer(_, let text):
            type = ChatViewMessageType.text(text: text)
        case .sticker:
            if let sticker = stickersRepository.sticker(text) {
                type = ChatViewMessageType.sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.text(text: text)
            }
        case .phone:
            type = ChatViewMessageType.text(text: R.Strings.professionalDealerAskPhoneChatMessage(text))
        case .meeting:
            type = ChatViewMessageType.text(text: text)
        case .multiAnswer(let question, _):
            type = ChatViewMessageType.multiAnswer(question: question, answers: [])
        case .interlocutorIsTyping:
            type = ChatViewMessageType.interlocutorIsTyping
        case .cta(let ctaData, let ctas):
            type = ChatViewMessageType.cta(ctaData: ctaData, ctas: ctas)
        case .unsupported(let defaultText):
            type = ChatViewMessageType.unsupported(text: defaultText ?? R.Strings.chatMessageTypeNotSupported)
        case .carousel:
            type = ChatViewMessageType.unsupported(text: R.Strings.chatMessageTypeNotSupported)
        // ABIOS-4837 waiting for back-end implementation to show this new message type
//        case .carousel(let cards, let answers):
//            type = ChatViewMessageType.carousel(cards: cards, answers: answers)
        }
        return ChatViewMessage(objectId: message.objectId,
                               talkerId: message.talkerId,
                               sentAt: message.sentAt,
                               receivedAt: nil,
                               readAt: nil,
                               type: type,
                               status: nil,
                               warningStatus: ChatViewMessageWarningStatus(status: message.warnings),
                               userAvatarData: userAvatarData)
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
                message = NSAttributedString(string: R.Strings.chatForbiddenDisclaimerBuyerWName(otherUserName))
            } else {
                message = NSAttributedString(string: R.Strings.chatForbiddenDisclaimerBuyerWoName)
            }
            chatBlockedMessage.append(message)
            chatBlockedMessage.append(NSAttributedString(string: " "))
            let keyword = R.Strings.chatBlockedDisclaimerScammerAppendSafetyTipsKeyword
            let secondPhraseStr = R.Strings.chatBlockedDisclaimerScammerAppendSafetyTips(keyword)
            let secondPhraseNSStr = NSString(string: secondPhraseStr)
            let range = secondPhraseNSStr.range(of: keyword)

            let secondPhrase = NSMutableAttributedString(string: secondPhraseStr)
            if range.location != NSNotFound {
                secondPhrase.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.primaryColor, range: range)
            }
            chatBlockedMessage.append(secondPhrase)
        } else {
            if let otherUserName = userName {
                message = NSAttributedString(string: R.Strings.chatForbiddenDisclaimerSellerWName(otherUserName))
            } else {
                message = NSAttributedString(string: R.Strings.chatForbiddenDisclaimerSellerWoName)
            }
            chatBlockedMessage.append(message)
        }

        return createDisclaimerMessage(chatBlockedMessage, showAvatar: true, actionTitle: nil, action: action)
    }

    func createUserDeletedDisclaimerMessage(_ userName: String?) -> ChatViewMessage {
        let chatDeletedMessage = ChatViewMessageAdapter.alertMutableAttributedString
        let message: String
        if let otherUserName = userName {
            message = R.Strings.chatDeletedDisclaimerWName(otherUserName)
        } else {
            message = R.Strings.chatDeletedDisclaimerWoName
        }
        chatDeletedMessage.append(NSAttributedString(string: message))
        return createDisclaimerMessage(chatDeletedMessage, showAvatar: true, actionTitle: nil, action: nil)
    }

    func createMessageSuspiciousDisclaimerMessage(_ action: (() -> ())?) -> ChatViewMessage {
        let messageSuspiciousMessage = ChatViewMessageAdapter.alertMutableAttributedString
        var keyword = ""
        if let _ = action {
             keyword = R.Strings.chatMessageDisclaimerScammerAppendBlocked
        }
        let secondPhraseStr = R.Strings.chatMessageDisclaimerScammerBaseBlocked(keyword)
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
        message.append(NSAttributedString(string: R.Strings.chatMessageDisclaimerMeetingSecurity))
        return createDisclaimerMessage(message, showAvatar: false, actionTitle: nil, action: nil)
    }

    func createUserInfoMessage(_ user: User?, userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage? {
        guard let user = user else { return nil }
        let facebook = user.facebookAccount?.verified ?? false
        let google = user.googleAccount?.verified ?? false
        let email = user.emailAccount?.verified ?? false
        let name = R.Strings.chatUserInfoName(user.name ?? "")
        let address = user.postalAddress.zipCodeCityString
 
        let chatUserInfo = ChatUserInfo(
            isDummy: user.isDummy,
            name: name,
            address: address,
            rating: user.ratingAverage,
            isFacebookVerified: facebook,
            isGoogleVerified: google,
            isEmailVerified: email
        )
        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                               type: .userInfo(userInfo: chatUserInfo),
                               status: nil, warningStatus: .normal,
                               userAvatarData: userAvatarData)
    }

    func createAskPhoneMessageWith(action: (() -> Void)?, userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage? {

        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: Date(), receivedAt: nil, readAt: nil,
                               type: .askPhoneNumber(text: R.Strings.professionalDealerAskPhoneAddPhoneCellMessage,
                                                     action: action),
                               status: nil, warningStatus: .normal,
                               userAvatarData: userAvatarData)
    }

    func createAutomaticAnswerWith(message: String, userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage? {
        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: Date(), receivedAt: nil, readAt: nil,
                               type: .text(text: message), status: nil, warningStatus: .normal,
                               userAvatarData: userAvatarData)
    }

    func createInterlocutorIsTyping(userAvatarData: ChatMessageAvatarData?) -> ChatViewMessage {
        return ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                               type: .interlocutorIsTyping, status: nil, warningStatus: .normal,
                               userAvatarData: userAvatarData)
    }
    
    private func createDisclaimerMessage(_ disclaimerText: NSAttributedString, showAvatar: Bool, actionTitle: String?,
                                         action: (() -> ())?) -> ChatViewMessage {
        let disclaimer = ChatViewMessageType.disclaimer(text: disclaimerText, action: action)
        let disclaimerMessage = ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                                                type: disclaimer, status: nil, warningStatus: .normal,
                                                userAvatarData: nil)
        return disclaimerMessage
    }

    private static var alertMutableAttributedString: NSMutableAttributedString {
        let icon = NSTextAttachment()
        icon.image = R.Asset.BackgroundsAndImages.icAlertGray.image
        let iconString = NSAttributedString(attachment: icon)
        let alertString = NSMutableAttributedString(attributedString: iconString)
        alertString.append(NSAttributedString(string: " "))
        return alertString
    }
}
