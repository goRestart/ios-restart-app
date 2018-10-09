import LGCoreKit
import RxSwift
import LGComponents

protocol ChatInactiveConversationsViewModelDelegate: BaseViewModelDelegate {
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?)
}

final class ChatInactiveConversationDetailsViewModel: BaseViewModel {
    
    weak var delegate: ChatInactiveConversationsViewModelDelegate?
    var navigator: ChatInactiveDetailNavigator?
    
    private let chatRepository: ChatRepository
    private let myUserRepository: MyUserRepository
    private let chatViewMessageAdapter: ChatViewMessageAdapter
    private let featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    
    private let conversation: ChatInactiveConversation

    private var isDeleted = false

    let messages = Variable<[ChatViewMessage]>([])
    private let interlocutorAvatar = Variable<UIImage?>(nil)
    
    private let disposeBag = DisposeBag()
    
    var messagesCount: Int {
        return messages.value.count
    }
    var listingName: String? {
        return conversation.listing?.title
    }
    var listingPrice: String? {
        return conversation.listing?.priceString()
    }
    var listingImageURL: URL? {
        return conversation.listing?.image?.fileURL
    }
    private var interlocutor: InactiveInterlocutor? {
        return conversation.interlocutor(forMyUserId: myUserRepository.myUser?.objectId)
    }
    var interlocutorName: String? {
        return interlocutor?.name
    }
    var interlocutorAvatarURL: URL? {
        return interlocutor?.avatar?.fileURL
    }
    var interlocutorAvatarPlaceholder: UIImage? {
        return LetgoAvatar.avatarWithID(interlocutor?.objectId,
                                        name: interlocutor?.name)
    }
    var meetingsEnabled: Bool {
        return featureFlags.chatNorris.isActive
    }
    
    // MARK: - Lifecycle
    
    convenience init(conversation: ChatInactiveConversation) {
        self.init(conversation: conversation,
                  chatRepository: Core.chatRepository,
                  myUserRepository: Core.myUserRepository,
                  chatViewMessageAdapter: ChatViewMessageAdapter(),
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(conversation: ChatInactiveConversation,
         chatRepository: ChatRepository,
         myUserRepository: MyUserRepository,
         chatViewMessageAdapter: ChatViewMessageAdapter,
         featureFlags: FeatureFlaggeable,
         tracker: Tracker) {
        self.conversation = conversation
        self.chatRepository = chatRepository
        self.myUserRepository = myUserRepository
        self.chatViewMessageAdapter = chatViewMessageAdapter
        self.featureFlags = featureFlags
        self.tracker = tracker
        super.init()
        setupRx()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        if firstTime {
            tracker.trackEvent(TrackerEvent.chatInactiveConversationsShown())
            retrieveInterlocutorAvatar()
        }
    }
    
    // MARK: - Messages
    
    func messageAtIndex(_ index: Int) -> ChatViewMessage? {
        guard 0..<messagesCount ~= index else { return nil }
        return messages.value[index]
    }
    
    func textOfMessageAtIndex(_ index: Int) -> String? {
        return messageAtIndex(index)?.value
    }
    
    // MARK: - Options Menu
    
    func openOptionsMenu() {
        var actions: [UIAction] = []
        if !isDeleted {
            let delete = UIAction(interface: UIActionInterface.text(R.Strings.chatListDelete),
                                  action: deleteAction)
            actions.append(delete)
        }
        delegate?.vmShowActionSheet(R.Strings.commonCancel, actions: actions)
    }
    
    private func deleteAction() {
        guard !isDeleted else { return }
        let action = UIAction(interface: .styledText(R.Strings.chatListDeleteAlertSend, .destructive), action: {
            [weak self] in
            self?.delete() { [weak self] success in
                if success {
                    self?.isDeleted = true
                    self?.tracker.trackEvent(TrackerEvent.chatDeleteComplete(numberOfConversations: 1,
                                                                             isInactiveConversation: true))
                }
                let message = success ? R.Strings.chatListDeleteOkOne : R.Strings.chatListDeleteErrorOne
                self?.delegate?.vmDidNotifyMessage(message) { [weak self] in
                    self?.navigator?.closeChatInactiveDetail()
                }
            }
        })
        delegate?.vmShowAlert(R.Strings.chatListDeleteAlertTitleOne,
                              message: R.Strings.chatListDeleteAlertTextOne,
                              cancelLabel: R.Strings.commonCancel,
                              actions: [action])
    }
    
    private func delete(_ completion: @escaping (_ success: Bool) -> ()) {
        guard let chatId = conversation.objectId else {
            completion(false)
            return
        }
        self.chatRepository.archiveInactiveConversations([chatId]) { result in
            completion(result.value != nil)
        }
    }

    private func retrieveInterlocutorAvatar() {
        guard let interlocutor = conversation.interlocutor(forMyUserId: myUserRepository.myUser?.objectId),
            featureFlags.showChatHeaderWithoutUser else {
                interlocutorAvatar.value = nil
                return
        }
        let placeholder = LetgoAvatar.avatarWithID(interlocutor.objectId, name: interlocutor.name)

        if let avatarUrl = interlocutor.avatar?.fileURL {
            do {
                interlocutorAvatar.value = try UIImage.imageFrom(url: avatarUrl)
            } catch {
                interlocutorAvatar.value = placeholder
            }
        } else {
            interlocutorAvatar.value = placeholder
        }
    }

    private func setupRx() {
        interlocutorAvatar.asDriver().skip(1).drive(onNext: { [weak self] userAvatar in
            guard let strongSelf = self else { return }
            strongSelf.messages.value = strongSelf.conversation.messages.compactMap { message in
                let avatarData = ChatMessageAvatarData(avatarImage: userAvatar, avatarAction: nil)
                return strongSelf.chatViewMessageAdapter.adapt(message, userAvatarData: avatarData)
            }
        }).disposed(by: disposeBag)
    }
}
