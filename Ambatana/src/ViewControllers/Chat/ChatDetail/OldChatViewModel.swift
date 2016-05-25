//
//  OldChatViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result
import RxSwift

protocol OldChatViewModelDelegate: class {
    
    func vmDidStartRetrievingChatMessages(hasData hasData: Bool)
    func vmDidFailRetrievingChatMessages()
    func vmDidSucceedRetrievingChatMessages()
    func vmUpdateAfterReceivingMessagesAtPositions(positions: [Int])
    
    func vmDidFailSendingMessage()
    func vmDidSucceedSendingMessage()
    
    func vmDidUpdateDirectAnswers()
    func vmDidUpdateProduct(messageToShow message: String?)
    
    func vmShowProduct(productVC: UIViewController)
    func vmShowProductRemovedError()
    func vmShowProductSoldError()
    func vmShowUser(userVM: UserViewModel)
    
    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel)
    
    func vmShowSafetyTips()
    func vmAskForRating()
    func vmShowPrePermissions(type: PrePermissionType)
    func vmShowKeyboard()
    func vmHideKeyboard()
    func vmShowMessage(message: String, completion: (() -> ())?)
    func vmShowOptionsList(options: [String], actions: [()->Void])
    func vmShowQuestion(title title: String, message: String, positiveText: String, positiveAction: (()->Void)?,
                              positiveActionStyle: UIAlertActionStyle?, negativeText: String, negativeAction: (()->Void)?,
                              negativeActionStyle: UIAlertActionStyle?)
    func vmClose()
    
    func vmUpdateRelationInfoView(status: ChatInfoViewStatus)
    func vmUpdateChatInteraction(enabled: Bool)
    
    func vmDidUpdateStickers()
}

enum AskQuestionSource {
    case ProductList
    case ProductDetail
}

public class OldChatViewModel: BaseViewModel, Paginable {
    
    
    // MARK: > Public data
    
    var fromMakeOffer = false
    var askQuestion: AskQuestionSource?
    
    // MARK: > Controller data
    
    weak var delegate: OldChatViewModelDelegate?
    var title: String? {
        return product.name
    }
    var productName: String? {
        return product.name
    }
    var productImageUrl: NSURL? {
        return product.thumbnail?.fileURL
    }
    var productUserName: String? {
        return product.user.name
    }
    var productPrice: String {
        return product.priceString()
    }
    var productStatus: ProductStatus {
        return product.status
    }
    var otherUserAvatarUrl: NSURL? {
        return otherUser?.avatar?.fileURL
    }
    var otherUserID: String? {
        return otherUser?.objectId
    }
    var otherUserName: String? {
        return otherUser?.name
    }
    var otherUser: User?
    var stickers: [Sticker] = []

    var userRelation: UserUserRelation? {
        didSet {
            delegate?.vmUpdateRelationInfoView(chatStatus)
            if let relation = userRelation where relation.isBlocked || relation.isBlockedBy {
                delegate?.vmHideKeyboard()
                showDirectAnswers(false)
            } else {
                showDirectAnswers(shouldShowDirectAnswers)
            }
            delegate?.vmUpdateChatInteraction(chatEnabled)
        }
    }
    
    var shouldShowDirectAnswers: Bool {
        return chatEnabled && KeyValueStorage.sharedInstance.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)
    }
    var keyForTextCaching: String {
        return userDefaultsSubKey
    }
    
    var chatStatus: ChatInfoViewStatus {
        if chat.forbidden {
            return .Forbidden
        }
        
        if let relation = userRelation {
            if relation.isBlocked { return .Blocked }
            if relation.isBlockedBy { return .BlockedBy }
        }
        
        switch product.status {
        case .Deleted, .Discarded:
            return .ProductDeleted
        case .Sold, .SoldOld:
            return .ProductSold
        case .Approved, .Pending:
            return .Available
        }
    }
    
    var chatEnabled: Bool {
        switch chatStatus {
        case .Forbidden, .Blocked, .BlockedBy:
            return false
        case .Available, .ProductSold, .ProductDeleted:
            return true
        }
    }

    var chatBlockedViewVisible: Bool {
        return chat.forbidden
    }

    var chatBlockedViewMessage: NSAttributedString? {
        guard chatBlockedViewVisible else { return nil }

        let icon = NSTextAttachment()
        icon.image = UIImage(named: "ic_alert_gray")
        let iconString = NSAttributedString(attachment: icon)
        let chatBlockedMessage = NSMutableAttributedString(attributedString: iconString)
        chatBlockedMessage.appendAttributedString(NSAttributedString(string: " "))

        let firstPhrase: NSAttributedString
        if let otherUserName = otherUserName {
            firstPhrase = NSAttributedString(string: LGLocalizedString.chatBlockedDisclaimerScammerWName(otherUserName))
        } else {
            firstPhrase = NSAttributedString(string: LGLocalizedString.chatBlockedDisclaimerScammerWoName)
        }
        chatBlockedMessage.appendAttributedString(firstPhrase)

        if isBuyer {
            chatBlockedMessage.appendAttributedString(NSAttributedString(string: " "))
            let keyword = LGLocalizedString.chatBlockedDisclaimerScammerAppendSafetyTipsKeyword
            let secondPhraseStr = LGLocalizedString.chatBlockedDisclaimerScammerAppendSafetyTips(keyword)
            let secondPhraseNSStr = NSString(string: secondPhraseStr)
            let range = secondPhraseNSStr.rangeOfString(keyword)

            let secondPhrase = NSMutableAttributedString(string: secondPhraseStr)
            if range.location != NSNotFound {
                secondPhrase.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor, range: range)
            }
            chatBlockedMessage.appendAttributedString(secondPhrase)
        }
        return chatBlockedMessage
    }

    var chatBlockedViewAction: (() -> Void)? {
        guard chatBlockedViewVisible else { return nil }
        guard !isBuyer else { return nil }

        return { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        }
    }

    dynamic func chatBlockedViewPressed() {
        guard isBuyer else { return }
        
        delegate?.vmShowSafetyTips()
    }


    // MARK: Paginable
    
    var resultsPerPage: Int = Constants.numMessagesPerPage
    var firstPage: Int = 0
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return loadedMessages.count
    }
    
    
    // MARK: > Private data
    
    private let chatRepository: OldChatRepository
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let stickersRepository: StickersRepository
    private let tracker: Tracker
    
    private var chat: Chat
    private var product: Product
    private var isDeleted = false
    private var shouldAskProductSold: Bool = false
    private var userDefaultsSubKey: String {
        return "\(product.objectId) + \(buyer?.objectId)"
    }
    
    private var loadedMessages: [Message]
    private var buyer: User?
    private var isSendingMessage = false
    
    private var isBuyer: Bool {
        guard let buyerId = buyer?.objectId, myUserId = myUserRepository.myUser?.objectId else { return false }
        return buyerId == myUserId
    }
    private var shouldShowSafetyTips: Bool {
        return !KeyValueStorage.sharedInstance.userChatSafetyTipsShown && didReceiveMessageFromOtherUser
    }
    private var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        return chat.didReceiveMessageFrom(otherUserId)
    }
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    convenience init?(chat: Chat) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.oldChatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let stickersRepository = Core.stickersRepository
        self.init(chat: chat, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker)
    }
    
    convenience init?(product: Product) {
        guard let chatFromProduct = Core.oldChatRepository.newChatWithProduct(product) else { return nil }
        self.init(chat: chatFromProduct)
    }
    
    init?(chat: Chat, myUserRepository: MyUserRepository, chatRepository: OldChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, stickersRepository: StickersRepository, tracker: Tracker) {
        self.chat = chat
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.stickersRepository = stickersRepository
        self.tracker = tracker
        self.loadedMessages = []
        self.product = chat.product
        if let myUser = myUserRepository.myUser {
            self.isDeleted = chat.isArchived(myUser: myUser)
        }
        super.init()
        initUsers()
        loadStickers()
        if otherUser == nil { return nil }
        if buyer == nil { return nil }
        
        setupDeepLinksRx()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        guard !chat.forbidden else { return }   // only load messages if the chat is not forbidden
        retrieveFirstPage()
    }
    
    func didAppear() {
        if fromMakeOffer &&
            PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat(buyer: isBuyer)){
            fromMakeOffer = false
            delegate?.vmShowPrePermissions(.Chat(buyer: isBuyer))
        } else if !chatEnabled {
            delegate?.vmHideKeyboard()
        } else {
            delegate?.vmShowKeyboard()
        }
    }
    
    
    // MARK: - Public
    
    func productInfoPressed() {
        switch product.status {
        case .Deleted:
            delegate?.vmShowProductRemovedError()
        case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
            guard let productVC = ProductDetailFactory.productDetailFromProduct(product) else { return }
            delegate?.vmShowProduct(productVC)
        }
    }
    
    func userInfoPressed() {
        guard let user = otherUser else { return }
        let userVM = UserViewModel(user: user, source: .Chat)
        delegate?.vmShowUser(userVM)
    }
    
    func safetyTipsDismissed() {
        KeyValueStorage.sharedInstance.userChatSafetyTipsShown = true
    }
    
    func optionsBtnPressed() {
        var texts: [String] = []
        var actions: [()->Void] = []
        //Safety tips
        texts.append(LGLocalizedString.chatSafetyTips)
        actions.append({ [weak self] in self?.delegate?.vmShowSafetyTips() })
        
        //Direct answers
        if chatEnabled {
            texts.append(shouldShowDirectAnswers ? LGLocalizedString.directAnswersHide :
                LGLocalizedString.directAnswersShow)
            actions.append({ [weak self] in self?.toggleDirectAnswers() })
        }
        //Delete
        if chat.isSaved && !isDeleted {
            texts.append(LGLocalizedString.chatListDelete)
            actions.append({ [weak self] in self?.delete() })
        }
        //Report
        texts.append(LGLocalizedString.reportUserTitle)
        actions.append({ [weak self] in self?.reportUserPressed() })
        
        if let relation = userRelation where relation.isBlocked {
            texts.append(LGLocalizedString.chatUnblockUser)
            actions.append({ [weak self] in self?.unblockUserPressed() })
        } else {
            texts.append(LGLocalizedString.chatBlockUser)
            actions.append({ [weak self] in self?.blockUserPressed() })
        }
        
        delegate?.vmShowOptionsList(texts, actions: actions)
    }
    
    func messageAtIndex(index: Int) -> Message {
        return loadedMessages[index]
    }
    
    func textOfMessageAtIndex(index: Int) -> String {
        return loadedMessages[index].text
    }
    
    func sendSticker(sticker: Sticker) {
        sendMessage(sticker.name, isQuickAnswer: false, type: .Sticker)
    }
    
    func sendText(text: String, isQuickAnswer: Bool) {
        sendMessage(text, isQuickAnswer: isQuickAnswer, type: .Text)
    }
    
    private func sendMessage(text: String, isQuickAnswer: Bool, type: MessageType) {
        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        self.isSendingMessage = true
        
        chatRepository.sendText(message, product: product, recipient: toUser) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value {
                if let askQuestion = strongSelf.askQuestion {
                    strongSelf.askQuestion = nil
                    strongSelf.trackQuestion(askQuestion)
                }
                strongSelf.loadedMessages.insert(sentMessage, atIndex: 0)
                strongSelf.delegate?.vmDidSucceedSendingMessage()
                strongSelf.trackMessageSent(isQuickAnswer)
                strongSelf.afterSendMessageEvents()
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailSendingMessage()
            }
            strongSelf.isSendingMessage = false
        }
    }
    
    private func afterSendMessageEvents() {
        if shouldAskProductSold {
            shouldAskProductSold = false
            delegate?.vmShowQuestion(title: LGLocalizedString.directAnswerSoldQuestionTitle,
                                     message: LGLocalizedString.directAnswerSoldQuestionMessage,
                                     positiveText: LGLocalizedString.directAnswerSoldQuestionOk,
                                     positiveAction: { [weak self] in
                                        self?.markProductAsSold()
                },
                                     positiveActionStyle: nil,
                                     negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.Chat(buyer: isBuyer))
        } else if RatingManager.sharedInstance.shouldShowRating {
            delegate?.vmAskForRating()
        }
    }
    
    func isMatchingConversationData(data: ConversationData) -> Bool {
        switch data {
        case .Conversation(let conversationId):
            return conversationId == chat.objectId
        case let .ProductBuyer(productId, buyerId):
            return productId == product.objectId && buyerId == buyer?.objectId
        }
    }
    
    func retrieveUsersRelation() {
        
        guard let otherUserId = otherUser?.objectId else { return }
        
        userRepository.retrieveUserToUserRelation(otherUserId) { [weak self] result in
            if let value = result.value {
                self?.userRelation = value
            } else {
                self?.userRelation = nil
            }
        }
    }
    
    
    // MARK: - private methods
    
    private func initUsers() {
        guard let myUser = myUserRepository.myUser else { return }
        self.otherUser = chat.otherUser(myUser: myUser)
        self.buyer = chat.buyer
    }
    
    private func loadStickers() {
        stickersRepository.show { [weak self] result in
            if let value = result.value {
                self?.stickers = value
                self?.delegate?.vmDidUpdateStickers()
            }
        }
    }
    
    private func setupDeepLinksRx() {
        DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext { [weak self] deepLink in
            switch deepLink.action {
            case .Conversation(let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            case .Message(_, let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    /**
     Retrieves the specified number of the newest messages
     
     - parameter numResults: the num of messages to retrieve
     */
    private func retrieveFirstPageWithNumResults(numResults: Int) {
        
        guard let userBuyer = buyer else { return }
        
        guard canRetrieve else { return }
        
        isLoading = true
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: 0,
                                                   numResults: numResults) { [weak self] result in
                                                    guard let strongSelf = self else { return }
                                                    if let chat = result.value {
                                                        strongSelf.chat = chat
                                                        let insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(strongSelf.loadedMessages,
                                                                                                                     newMessages: chat.messages)
                                                        strongSelf.loadedMessages = insertedMessagesInfo.messages
                                                        strongSelf.delegate?.vmUpdateAfterReceivingMessagesAtPositions(insertedMessagesInfo.indexes)
                                                        strongSelf.afterRetrieveChatMessagesEvents()
                                                    }
                                                    strongSelf.isLoading = false
        }
    }
    
    /**
     Inserts messages from one array to another, avoiding to insert repetitions.
     
     Since messages sent are inserted at the table, but don't have Id, those messages are filtered
     when updating the table.
     
     - parameter mainMessages: the array with old items
     - parameter newMessages: the array with new items
     
     - returns: a struct with the FULL array (old + new) and the indexes of the NEW items
     */
    static func insertNewMessagesAt(mainMessages: [Message], newMessages: [Message])
        -> (messages: [Message], indexes: [Int]) {
            
            guard !newMessages.isEmpty else { return (mainMessages, []) }
            
            // - idxs: the positions of the table that will be inserted
            var idxs: [Int] = []
            
            var firstMsgObjectId: String? = nil
            var messagesWithId: [Message] = mainMessages
            
            // - messages sent don't have Id until the list is refreshed (push received or view appears)
            for message in mainMessages {
                if let objectId = message.objectId {
                    firstMsgObjectId = objectId
                    break
                }
                // last "sent messages" are removed, if any
                messagesWithId.removeFirst()
            }
            // myMessagesWithoutIdCount : num of positions that shouldn't be updated in the table
            let myMessagesWithoutIdCount = mainMessages.count - messagesWithId.count
            
            guard let firstMsgId = firstMsgObjectId,
                indexOfFirstNewItem = newMessages.indexOf({$0.objectId == firstMsgId}) else {
                    //If new messages count doesn't reach the ones without id, it means backend didn't process all of
                    //them yet so let's keep the old ones
                    guard newMessages.count-myMessagesWithoutIdCount >= 0 else { return (mainMessages, []) }
                    //Update non-id with new ones plus the extra ones
                    for i in 0..<newMessages.count-myMessagesWithoutIdCount { idxs.append(i) }
                    return (newMessages + messagesWithId, idxs)
            }
            
            // newMessages can be a whole page, so "reallyNewMessages" are only the ones
            // that come as newMessages and haven't been loaded before
            let reallyNewMessages = newMessages[0..<indexOfFirstNewItem]
            if reallyNewMessages.count-myMessagesWithoutIdCount >= 0 {
                for i in 0..<reallyNewMessages.count-myMessagesWithoutIdCount { idxs.append(i) }
            }
            
            return (reallyNewMessages + messagesWithId, idxs)
    }
    
    private func onProductSoldDirectAnswer() {
        if chatStatus != .ProductSold {
            shouldAskProductSold = true
        }
    }
    
    private func clearProductSoldDirectAnswer() {
        shouldAskProductSold = false
    }
    
    private func blockUserPressed() {
        
        delegate?.vmShowQuestion(title: LGLocalizedString.chatBlockUserAlertTitle,
                                 message: LGLocalizedString.chatBlockUserAlertText,
                                 positiveText: LGLocalizedString.chatBlockUserAlertBlockButton,
                                 positiveAction: { [weak self] in
                                    self?.blockUser() { [weak self] success in
                                        if success {
                                            self?.userRelation?.isBlocked = true
                                        } else {
                                            self?.delegate?.vmShowMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                                        }
                                    }
            },
                                 positiveActionStyle: .Destructive,
                                 negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }
    
    private func blockUser(completion: (success: Bool) -> ()) {
        
        guard let user = otherUser, let userId = user.objectId else {
            completion(success: false)
            return
        }
        
        trackBlockUsers([userId])
        
        self.userRepository.blockUserWithId(userId) { result -> Void in
            completion(success: result.value != nil)
        }
    }
    
    private func unblockUserPressed() {
        unBlockUser() { [weak self] success in
            if success {
                self?.userRelation?.isBlocked = false
            } else {
                self?.delegate?.vmShowMessage(LGLocalizedString.unblockUserErrorGeneric, completion: nil)
            }
        }
    }
    
    private func unBlockUser(completion: (success: Bool) -> ()) {
        guard let user = otherUser, let userId = user.objectId else {
            completion(success: false)
            return
        }
        
        trackUnblockUsers([userId])
        
        self.userRepository.unblockUserWithId(userId) { result -> Void in
            completion(success: result.value != nil)
        }
    }
    
    private func toggleDirectAnswers() {
        showDirectAnswers(!shouldShowDirectAnswers)
    }
    
    private func delete() {
        guard !isDeleted else { return }
        
        delegate?.vmShowQuestion(title: LGLocalizedString.chatListDeleteAlertTitleOne,
                                 message: LGLocalizedString.chatListDeleteAlertTextOne,
                                 positiveText: LGLocalizedString.chatListDeleteAlertSend,
                                 positiveAction: { [weak self] in
                                    self?.delete() { [weak self] success in
                                        if success {
                                            self?.isDeleted = true
                                        }
                                        let message = success ? LGLocalizedString.chatListDeleteOkOne : LGLocalizedString.chatListDeleteErrorOne
                                        self?.delegate?.vmShowMessage(message) { [weak self] in
                                            self?.delegate?.vmClose()
                                        }
                                    }
            },
                                 positiveActionStyle: .Destructive,
                                 negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }
    
    private func delete(completion: (success: Bool) -> ()) {
        guard let chatId = chat.objectId else {
            completion(success: false)
            return
        }
        self.chatRepository.archiveChatsWithIds([chatId]) { result in
            completion(success: result.value != nil)
        }
    }
    
    private func reportUserPressed() {
        guard let otherUserId = otherUser?.objectId else { return }
        let reportVM = ReportUsersViewModel(origin: .Chat, userReportedId: otherUserId)
        delegate?.vmShowReportUser(reportVM)
    }
    
    private func markProductAsSold() {
        productRepository.markProductAsSold(product) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.product = value
                strongSelf.delegate?.vmDidUpdateProduct(messageToShow: LGLocalizedString.productMarkAsSoldSuccessMessage)
                strongSelf.delegate?.vmUpdateRelationInfoView(strongSelf.chatStatus)
            } else {
                strongSelf.delegate?.vmShowMessage(LGLocalizedString.productMarkAsSoldErrorGeneric, completion: nil)
            }
        }
    }
    
    
    // MARK: Tracking
    
    private func trackQuestion(source: AskQuestionSource) {
        // only track ask question if there were no previous messages
        guard objectCount == 0 else { return }
        let typePageParam: EventParameterTypePage
        switch source {
        case .ProductDetail:
            typePageParam = .ProductDetail
        case .ProductList:
            typePageParam = .ProductList
        }
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, typePage: typePageParam, directChat: .False,
                                                               longPress: .False)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }
    
    private func trackMessageSent(isQuickAnswer: Bool) {
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: otherUser,
                                                            isQuickAnswer: isQuickAnswer ? .True : .False, directChat: .False, longPress: .False)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }
    
    private func trackBlockUsers(userIds: [String]) {
        let blockUserEvent = TrackerEvent.profileBlock(.Chat, blockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(blockUserEvent)
    }
    
    private func trackUnblockUsers(userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.Chat, unblockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
    
    // MARK: - Paginable
    
    func retrievePage(page: Int) {
        
        guard let userBuyer = buyer else { return }
        
        delegate?.vmDidStartRetrievingChatMessages(hasData: !loadedMessages.isEmpty)
        isLoading = true
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: page,
                                                   numResults: resultsPerPage) { [weak self] result in
                                                    guard let strongSelf = self else { return }
                                                    if let chat = result.value {
                                                        if page == 0 {
                                                            strongSelf.loadedMessages = chat.messages
                                                        } else {
                                                            strongSelf.loadedMessages += chat.messages
                                                        }
                                                        strongSelf.isLastPage = chat.messages.count < strongSelf.resultsPerPage
                                                        strongSelf.chat = chat
                                                        strongSelf.nextPage = page + 1
                                                        strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
                                                        strongSelf.afterRetrieveChatMessagesEvents()
                                                    } else if let error = result.error {
                                                        switch (error) {
                                                        case .NotFound:
                                                            //New chat!! this is success
                                                            strongSelf.isLastPage = true
                                                            strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
                                                            strongSelf.afterRetrieveChatMessagesEvents()
                                                        case .Network, .Unauthorized, .Internal, .Forbidden:
                                                            strongSelf.delegate?.vmDidFailRetrievingChatMessages()
                                                        }
                                                    }
                                                    strongSelf.isLoading = false
        }
    }
    
    private func afterRetrieveChatMessagesEvents() {
        guard shouldShowSafetyTips else { return }
        delegate?.vmShowSafetyTips()
    }
}


// MARK: - DirectAnswers

extension OldChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [DirectAnswer] {
        let emptyAction: ()->Void = { [weak self] in
            self?.clearProductSoldDirectAnswer()
        }
        if isBuyer {
            return [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerIsNegotiable, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerLikeToBuy, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction)]
        } else {
            return [DirectAnswer(text: LGLocalizedString.directAnswerStillForSale, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerWhatsOffer, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNegotiableYes, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNegotiableNo, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerProductSold, action: { [weak self] in
                        self?.onProductSoldDirectAnswer()
                        })]
        }
    }
    
    func directAnswersDidTapAnswer(controller: DirectAnswersPresenter, answer: DirectAnswer) {
        if let actionBlock = answer.action {
            actionBlock()
        }
        sendText(answer.text, isQuickAnswer: true)
    }
    
    func directAnswersDidTapClose(controller: DirectAnswersPresenter) {
        showDirectAnswers(false)
    }
    
    private func showDirectAnswers(show: Bool) {
        KeyValueStorage.sharedInstance.userSaveChatShowDirectAnswersForKey(userDefaultsSubKey, value: show)
        delegate?.vmDidUpdateDirectAnswers()
    }
}