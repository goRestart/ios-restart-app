//
//  ChatListInactiveConversationsViewModel.swift
//  LetGo
//
//  Created by Nestor on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

protocol ChatInactiveConversationsListViewModelProtocol: RxPaginable {
    var editing: Variable<Bool> { get }
}

protocol ChatInactiveConversationsListViewModelDelegate: class {
    func didStartRetrievingObjectList()
    func didFailRetrievingObjectList(_ page: Int)
    func didSucceedRetrievingObjectList(_ page: Int)
    
    func didFailArchivingChats()
    func didSucceedArchivingChats()
    func didFailUnarchivingChats()
    func didSucceedUnarchivingChats()
    func shouldShowDeleteConfirmation(title: String,
                                      message: String,
                                      cancelText: String,
                                      actionText: String,
                                      action: @escaping () -> ())
}

class ChatInactiveConversationsListViewModel: BaseViewModel, ChatInactiveConversationsListViewModelProtocol {
    weak var delegate: ChatInactiveConversationsListViewModelDelegate?
    weak var navigator: TabNavigator?
    
    private var chatRepository: ChatRepository
    private let tracker: Tracker
    
    let conversations = Variable<[ChatInactiveConversation]>([])
    let selectedConversationIds = Variable<[String]>([])
    let rx_objectCount = Variable<Int>(0)
    
    let editing = Variable<Bool>(false)
    let editButtonEnabled = Variable<Bool>(true)
    let editButtonText = Variable<String?>(nil)
    let deleteButtonEnabled = Variable<Bool>(false)
    let status = Variable<ViewState>(.loading)

    private let disposeBag = DisposeBag()
    
    var emptyStatusViewModel: LGEmptyViewModel {
        return LGEmptyViewModel(icon: UIImage(named: "err_list_no_chats"),
                                title: LGLocalizedString.chatListAllEmptyTitle,
                                body: nil,
                                buttonTitle: nil,
                                action: nil,
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: nil,
                                errorCode: nil)
    }
    
    // MARK: - Lifecycle
    
    convenience init(navigator: TabNavigator?) {
        self.init(navigator: navigator,
                  chatRepository: Core.chatRepository,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    required init(navigator: TabNavigator?,
                  chatRepository: ChatRepository,
                  tracker: Tracker) {
        self.chatRepository = chatRepository
        self.tracker = tracker
        super.init()
        setupRx()
    }
    
    func clean() {
        chatRepository.cleanInactiveConversations()
    }
    
    // MARK: - RX
    
    func setupRx() {
        chatRepository.inactiveConversations.asObservable()
            .bind(to: conversations)
            .disposed(by: disposeBag)
        
        conversations.asObservable()
            .map { conversations in
                return conversations.count > 0
            }
            .bind(to: editButtonEnabled)
            .disposed(by: disposeBag)
        
        selectedConversationIds.asObservable()
            .map { $0.count > 0 }
            .bind(to: deleteButtonEnabled)
            .disposed(by: disposeBag)
        
        editing.asObservable()
            .map { [weak self] editing in
                return self?.editButtonText(forEditing: editing)
            }
            .bind(to: editButtonText)
            .disposed(by: disposeBag)
        
        status.asObservable()
            .subscribeNext { [weak self] viewState in
                switch viewState {
                case let .error(emptyVM):
                    if let emptyReason = self?.emptyViewModel?.emptyReason {
                        self?.trackErrorStateShown(reason: emptyReason, errorCode: emptyVM.errorCode)
                    }
                case .loading, .data, .empty:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Conversations
    
    func openConversation(index: Int) {
        guard let conversation = objectAtIndex(index) else { return }
        navigator?.openChat(.inactiveConversation(coversation: conversation),
                            source: .chatList,
                            predefinedMessage: nil)
    }
    
    func isConversationSelected(index: Int) -> Bool {
        guard let conversation = objectAtIndex(index),
            let id = conversation.objectId
            else { return false }
        return selectedConversationIds.value.contains(id)
    }
    
    func selectConversation(index: Int, editing: Bool) {
        guard let conversation = objectAtIndex(index),
            let id = conversation.objectId
            else { return }
        if editing {
            selectedConversationIds.value.append(id)
        } else {
            navigator?.openChat(.inactiveConversation(coversation: conversation),
                                   source: .chatList,
                                   predefinedMessage: nil)
        }
    }
    
    func deselectConversation(index: Int, editing: Bool) {
        guard editing,
            let conversation = objectAtIndex(index),
            let id = conversation.objectId,
            let indexInArray = selectedConversationIds.value.index(of: id)
            else { return }
        selectedConversationIds.value.remove(at: indexInArray)
    }
    
    func deselectAllConversations() {
        selectedConversationIds.value.removeAll()
    }
    
    func conversationDataAtIndex(_ index: Int) -> ConversationCellData? {
        guard let conversation = objectAtIndex(index) else { return nil }
        return ConversationCellData(status: .available,
                                    userName: conversation.interlocutor?.name ?? "",
                                    userImageUrl: conversation.interlocutor?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(conversation.interlocutor?.objectId,
                                                                                   name: conversation.interlocutor?.name),
                                    listingName: conversation.listing?.name ?? "",
                                    listingImageUrl: conversation.listing?.image?.fileURL,
                                    unreadCount: 0,
                                    messageDate: nil)
    }
    
    func objectAtIndex(_ index: Int) -> ChatInactiveConversation? {
        guard index < conversations.value.count else { return nil }
        return conversations.value[index]
    }
    
    func selectedObjectsAtIndexes(_ indexes: [Int]) -> [ChatInactiveConversation]? {
        return indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap { conversations.value[$0] }
    }
    
    // MARK: - Delete Inactive Conversations
    
    func deleteButtonPressed() {
        guard !selectedConversationIds.value.isEmpty else { return }
        let count = selectedConversationIds.value.count
        delegate?.shouldShowDeleteConfirmation(title: deleteConfirmationTitle(count),
                                               message: deleteConfirmationMessage(count),
                                               cancelText: deleteConfirmationCancelTitle(),
                                               actionText: deleteConfirmationSendButton()) { [weak self] in
                                                self?.deleteSelectedChats()
        }
    }
    
    private func deleteConfirmationTitle(_ itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTitleOne :
            LGLocalizedString.chatListDeleteAlertTitleMultiple
    }
    
    private func deleteConfirmationMessage(_ itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTextOne :
            LGLocalizedString.chatListDeleteAlertTextMultiple
    }
    
    private func deleteConfirmationCancelTitle() -> String {
        return LGLocalizedString.commonCancel
    }
    
    private func deleteConfirmationSendButton() -> String {
        return LGLocalizedString.chatListDeleteAlertSend
    }
    
    private func deleteSelectedChats() {
        guard !selectedConversationIds.value.isEmpty else {
            delegate?.didFailArchivingChats()
            return
        }
        chatRepository.archiveInactiveConversations(selectedConversationIds.value) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.didFailArchivingChats()
            } else {
                strongSelf.delegate?.didSucceedArchivingChats()
            }
        }
    }
    
    // MARK: - Tracking
    
    func trackErrorStateShown(reason: EventParameterEmptyReason, errorCode: Int?) {
        let event = TrackerEvent.emptyStateVisit(typePage: .chatList, reason: reason, errorCode: errorCode)
        tracker.trackEvent(event)
    }
    
    // MARK: Helpers
    
    func editButtonText(forEditing editing: Bool) -> String {
        return editing ? LGLocalizedString.commonCancel : LGLocalizedString.chatListDelete
    }
    
    var activityIndicatorAnimating: Bool {
        switch status.value {
        case .empty, .error, .data:
            return false
        case .loading:
            return true
        }
    }
    
    var emptyViewHidden: Bool {
        switch status.value {
        case .empty, .error:
            return false
        case .loading, .data:
            return true
        }
    }
    
    var emptyViewModel: LGEmptyViewModel? {
        switch status.value {
        case let .empty(viewModel):
            return viewModel
        case let .error(viewModel):
            return viewModel
        case .loading, .data:
            return nil
        }
    }
    
    var tableViewHidden: Bool {
        switch status.value {
        case .empty, .error, .loading:
            return true
        case .data:
            return false
        }
    }
    
    private func emptyViewModelForError(_ error: RepositoryError) -> LGEmptyViewModel {
        let retryAction: () -> () = { [weak self] in
            self?.retrieveFirstPage()
        }
        switch error {
        case let .network(errorCode, _):
            return LGEmptyViewModel.networkErrorWithRetry(errorCode: errorCode, action: retryAction)
        case let .wsChatError(chatRepositoryError):
            switch chatRepositoryError {
            case let .network(errorCode, _):
                return LGEmptyViewModel.networkErrorWithRetry(errorCode: errorCode, action: retryAction)
            case .internalError, .notAuthenticated, .userNotVerified, .userBlocked, .apiError, .differentCountry:
                return LGEmptyViewModel.genericErrorWithRetry(action: retryAction)
            }
        case .internalError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified, .serverError:
            return LGEmptyViewModel.genericErrorWithRetry(action: retryAction)
        }
    }
    
    // MARK: Paginable
    
    let firstPage: Int = 1
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return conversations.value.count
    }
    
    func retrievePage(_ page: Int) {
        let firstPage = (page == 1)
        isLoading = true
        delegate?.didStartRetrievingObjectList()
        let offset = max(0, page - 1) * resultsPerPage
        chatRepository.fetchInactiveConversations(limit: resultsPerPage, offset: offset) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1
                if firstPage && strongSelf.objectCount == 0 {
                    strongSelf.status.value = .empty(strongSelf.emptyStatusViewModel)
                } else {
                    strongSelf.status.value = .data
                }
                strongSelf.delegate?.didSucceedRetrievingObjectList(page)
            } else if let error = result.error {
                if firstPage && strongSelf.objectCount == 0 {
                    strongSelf.status.value = .error(strongSelf.emptyViewModelForError(error))
                } else {
                    strongSelf.status.value = .data
                }
                strongSelf.delegate?.didFailRetrievingObjectList(page)
            }
            strongSelf.isLoading = false
        }
    }
}

