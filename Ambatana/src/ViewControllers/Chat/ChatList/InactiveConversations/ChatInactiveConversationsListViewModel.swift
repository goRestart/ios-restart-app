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

protocol ChatInactiveConversationsListViewModelProtocol: Paginable {
    var editing: Variable<Bool> { get }
    func refresh(completion: (() -> Void)?)
}

protocol ChatInactiveConversationsListViewModelDelegate: class {
    func shouldUpdateStatus()
    func setEditing(_ editing: Bool)
    func didStartRetrievingObjectList()
    func didFailRetrievingObjectList(_ page: Int)
    func didSucceedRetrievingObjectList(_ page: Int)
    func didUpdateConversations()
    
    func didFailArchivingChats(viewModel: ChatInactiveConversationsListViewModel)
    func didSucceedArchivingChats(viewModel: ChatInactiveConversationsListViewModel)
    func didFailUnarchivingChats(viewModel: ChatInactiveConversationsListViewModel)
    func didSucceedUnarchivingChats(viewModel: ChatInactiveConversationsListViewModel)
    func viewModel(viewModel: ChatInactiveConversationsListViewModel,
                   showDeleteConfirmationWithTitle title: String,
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
    private var multipageRequester: MultiPageRequester<ChatInactiveConversation>?
    
    private var selectedConversationIds: Set<String>
    var objects = Variable<[ChatInactiveConversation]>([])
    
    let editing = Variable<Bool>(false)
    
    private(set) var status: ViewState = .loading {
        didSet {
            switch status {
            case let .error(emptyVM):
                if let emptyReason = emptyViewModel?.emptyReason {
                    trackErrorStateShown(reason: emptyReason, errorCode: emptyVM.errorCode)
                }
            case .loading, .data, .empty:
                break
            }
        }
    }
    
    let editButtonText = Variable<String?>(nil)
    let editButtonEnabled = Variable<Bool>(true)
    
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
                  tracker: Tracker) {        self.chatRepository = chatRepository
        self.selectedConversationIds = Set<String>()
        self.tracker = tracker
        super.init()
        objects.value = chatRepository.inactiveConversations.value
        multipageRequester = MultiPageRequester() { [weak self] (page, completion) in
            self?.fetchConversations(page: page, completion: completion)
        }
        setupRx()
    }
    
    // MARK: Conversations
    
    func isConversationSelected(index: Int) -> Bool {
        guard let conversation = objectAtIndex(index),
            let id = conversation.objectId else {
                return false
        }
        return selectedConversationIds.contains(id)
    }
    
    func selectConversation(index: Int, editing: Bool) {
        guard let conversation = objectAtIndex(index),
            let id = conversation.objectId else {
                return
        }
        if editing {
            selectedConversationIds.insert(id)
        } else {
            navigator?.openChat(.inactiveConversation(coversation: conversation),
                                   source: .chatList,
                                   predefinedMessage: nil)
        }
    }
    
    func deselectConversation(index: Int, editing: Bool) {
        guard let conversation = objectAtIndex(index), let id = conversation.objectId else { return }
        if editing {
            selectedConversationIds.remove(id)
        }
    }
    
    func deselectAllConversations() {
        selectedConversationIds.removeAll()
    }
    
    func openConversation(index: Int) {
        guard let conversation = objectAtIndex(index) else { return }
        navigator?.openChat(.inactiveConversation(coversation: conversation),
                               source: .chatList,
                               predefinedMessage: nil)
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
    
    // MARK: Delete inactive conversations
    
    func deleteButtonPressed() {
        guard !selectedConversationIds.isEmpty else { return }
        let count = selectedConversationIds.count
        delegate?.viewModel(
            viewModel: self,
            showDeleteConfirmationWithTitle: deleteConfirmationTitle(count),
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
        guard !selectedConversationIds.isEmpty else {
            delegate?.didFailArchivingChats(viewModel: self)
            return
        }
        let conversationIds = Array(selectedConversationIds)
        chatRepository.archiveConversations(conversationIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.didFailArchivingChats(viewModel: strongSelf)
            } else {
                strongSelf.delegate?.didSucceedArchivingChats(viewModel: strongSelf)
            }
        }
    }
    
    // MARK: - Tracking
    
    func trackErrorStateShown(reason: EventParameterEmptyReason, errorCode: Int?) {
        let event = TrackerEvent.emptyStateVisit(typePage: .chatList, reason: reason, errorCode: errorCode)
        tracker.trackEvent(event)
    }
    
    // MARK:
    
    func didFinishLoading() {
        
    }
    
    var activityIndicatorAnimating: Bool {
        switch status {
        case .empty, .error, .data:
            return false
        case .loading:
            return true
        }
    }
    
    var emptyViewHidden: Bool {
        switch status {
        case .empty, .error:
            return false
        case .loading, .data:
            return true
        }
    }
    
    var emptyViewModel: LGEmptyViewModel? {
        switch status {
        case let .empty(viewModel):
            return viewModel
        case let .error(viewModel):
            return viewModel
        case .loading, .data:
            return nil
        }
    }
    
    var tableViewHidden: Bool {
        switch status {
        case .empty, .error, .loading:
            return true
        case .data:
            return false
        }
    }
    
    private func emptyViewModelForError(_ error: RepositoryError) -> LGEmptyViewModel? {
        let retryAction: () -> () = { [weak self] in
            self?.retrieveFirstPage()
        }
        var emptyVM: LGEmptyViewModel?
        switch error {
        case let .network(errorCode, onBackground):
            emptyVM = onBackground ? nil : LGEmptyViewModel.networkErrorWithRetry(errorCode: errorCode, action: retryAction)
        case let .wsChatError(chatRepositoryError):
            switch chatRepositoryError {
            case let .network(errorCode, onBackground):
                emptyVM = onBackground ? nil : LGEmptyViewModel.networkErrorWithRetry(errorCode: errorCode, action: retryAction)
            case .internalError, .notAuthenticated, .userNotVerified, .userBlocked, .apiError, .differentCountry:
                emptyVM = LGEmptyViewModel.genericErrorWithRetry(action: retryAction)
            }
        case .internalError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified, .serverError:
            emptyVM = LGEmptyViewModel.genericErrorWithRetry(action: retryAction)
        }
        return emptyVM
    }
    
    func setupRx() {
        editing.asObservable().subscribeNext { [weak self] editing in
            self?.delegate?.setEditing(editing)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Paginable
    
    let firstPage: Int = 1
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return objects.value.count
    }
    
    func retrievePage(_ page: Int) {
        retrievePage(page, completion: nil)
    }
    
    // MARK: > fetch data
    
    func refresh(completion: (() -> Void)?) {
        guard canRetrieve else { return }
        if objectCount == 0 {
            retrievePage(firstPage, completion: completion)
        } else {
            reloadCurrentPagesWith(completion: completion)
        }
    }
    
    func retrievePage(_ page: Int, completion: (() -> Void)?) {
        let firstPage = (page == 1)
        isLoading = true
        var hasToRetrieveFirstPage: Bool = false
        delegate?.didStartRetrievingObjectList()
        
        fetchConversations(page: page) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                
                if firstPage {
                    strongSelf.updateObjects(newObjects: value)
                } else {
                    strongSelf.updateObjects(newObjects: strongSelf.objects.value + value)
                }
                
                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1
                
                if firstPage && strongSelf.objectCount == 0 {
                    strongSelf.status = .empty(strongSelf.emptyStatusViewModel)
                } else {
                    strongSelf.status = .data
                }
                strongSelf.delegate?.shouldUpdateStatus()
                strongSelf.delegate?.didSucceedRetrievingObjectList(page)
            } else if let error = result.error {
                
                if firstPage && strongSelf.objectCount == 0 {
                    if let emptyVM = strongSelf.emptyViewModelForError(error) {
                        strongSelf.status = .error(emptyVM)
                    } else {
                        hasToRetrieveFirstPage = true
                    }
                } else {
                    strongSelf.status = .data
                }
                strongSelf.delegate?.shouldUpdateStatus()
                strongSelf.delegate?.didFailRetrievingObjectList(page)
            }
            strongSelf.isLoading = false
            if hasToRetrieveFirstPage {
                strongSelf.retrieveFirstPage()
            }
            completion?()
        }
        didFinishLoading()
    }
    
    func fetchConversations(page: Int, completion: ((Result<[ChatInactiveConversation], RepositoryError>) -> ())?) {
        let offset = max(0, page - 1) * resultsPerPage
        chatRepository.fetchInactiveConversations(limit: resultsPerPage,
                                                  offset: offset,
                                                  completion: completion)
    }
    
    private func reloadCurrentPagesWith(completion: (() -> ())?) {
        guard firstPage < nextPage else {
            completion?()
            return
        }
        
        isLoading = true
        delegate?.didStartRetrievingObjectList()
        
        let pages: [Int] = Array(firstPage..<nextPage)
        multipageRequester?.request(pages: pages) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            
            if let reloadedData = result.value {
                if reloadedData.isEmpty {
                    strongSelf.status = .empty(strongSelf.emptyStatusViewModel)
                } else {
                    strongSelf.status = .data
                }
                strongSelf.updateObjects(newObjects: reloadedData)
                strongSelf.delegate?.didSucceedRetrievingObjectList(strongSelf.nextPage)
            } else if let error = result.error {
                if let emptyVM = strongSelf.emptyViewModelForError(error) {
                    strongSelf.status = .error(emptyVM)
                } else {
                    strongSelf.retrieveFirstPage()
                }
                
                strongSelf.updateObjects(newObjects: [])
                strongSelf.delegate?.didFailRetrievingObjectList(strongSelf.nextPage)
            }
            strongSelf.didFinishLoading()
            completion?()
        }
    }
    
    // MARK: > Data helpers
    
    func objectAtIndex(_ index: Int) -> ChatInactiveConversation? {
        guard index < objects.value.count else { return nil }
        return objects.value[index]
    }
    
    func selectedObjectsAtIndexes(_ indexes: [Int]) -> [ChatInactiveConversation]? {
        return indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap { objects.value[$0] }
    }
    
    func updateObjects(newObjects: [ChatInactiveConversation]) {
        objects.value = newObjects
        delegate?.didUpdateConversations()
    }
    
    func clear() {
        updateObjects(newObjects: [])
        nextPage = 1
        isLastPage = false
        isLoading = false
    }
}

