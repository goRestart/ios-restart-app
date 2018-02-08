//
//  ChatGroupedListViewModel.swift
//  LetGo
//
//  Created by Dídac on 15/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

/**
Defines the type shared across 'Chats' section lists.
*/
protocol ChatGroupedListViewModelType: RxPaginable {
    var editing: Variable<Bool> { get }
    func refresh(completion: (() -> Void)?)
}

protocol ChatGroupedListViewModelDelegate: class {
    func chatGroupedListViewModelShouldUpdateStatus()
    func chatGroupedListViewModelSetEditing(_ editing: Bool)
    func chatGroupedListViewModelDidStartRetrievingObjectList()
    func chatGroupedListViewModelDidFailRetrievingObjectList(_ page: Int)
    func chatGroupedListViewModelDidSucceedRetrievingObjectList(_ page: Int)
}

protocol ChatGroupedListViewModel: class, ChatGroupedListViewModelType {
    var chatGroupedDelegate: ChatGroupedListViewModelDelegate? { get set }
    var emptyStatusViewModel: LGEmptyViewModel? { get set }
    var activityIndicatorAnimating: Bool { get }
    var emptyViewModel: LGEmptyViewModel? { get }
    var emptyViewHidden: Bool { get }
    var tableViewHidden: Bool { get }
    var shouldRefreshConversationsTabTrigger: Bool { get set }
    var shouldScrollToTop: Observable<Bool> { get }
    func clear()
    func openInactiveConversations()
    var shouldShowInactiveConversations: Bool { get }
}

class BaseChatGroupedListViewModel<T>: BaseViewModel, ChatGroupedListViewModel {
    let objects: CollectionVariable<T>
    let shouldWriteInCollectionVariable: Bool
    let notificationsManager: NotificationsManager
    fileprivate let tracker: Tracker
    let featureFlags: FeatureFlaggeable
    
    private let chatRepository: ChatRepository
    let inactiveConversationsCount = Variable<Int?>(nil)
    
    private(set) var status: ViewState {
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

    var emptyStatusViewModel: LGEmptyViewModel?

    weak var chatGroupedDelegate : ChatGroupedListViewModelDelegate?
    weak var tabNavigator: TabNavigator?

    var shouldShowInactiveConversations: Bool {
        return featureFlags.showInactiveConversations
    }
    
    // MARK: - Paginable

    let firstPage: Int = 1
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false

    var objectCount: Int {
        return rx_objectCount.value
    }
    let rx_objectCount = Variable<Int>(0)
    let editing = Variable<Bool>(false)
    fileprivate let disposeBag = DisposeBag()
    fileprivate var inactiveDisposeBag = DisposeBag()

    private var multipageRequester: MultiPageRequester<T>?
    
    var shouldRefreshConversationsTabTrigger: Bool = true
    var shouldScrollToTop: Observable<Bool> {
        return shouldScrollToTopVar.asObservable().filter { $0 }
    }
    fileprivate let shouldScrollToTopVar = Variable<Bool>(false)

    
    // MARK: - Lifecycle

    convenience init(objects: [T],
                     tabNavigator: TabNavigator?,
                     notificationsManager: NotificationsManager = LGNotificationsManager.sharedInstance,
                     tracker: Tracker = TrackerProxy.sharedInstance,
                     chatRepository: ChatRepository = Core.chatRepository) {
        self.init(collectionVariable: CollectionVariable(objects),
                  shouldWriteInCollectionVariable: false,
                  tabNavigator: tabNavigator,
                  notificationsManager: notificationsManager,
                  tracker: tracker,
                  chatRepository: chatRepository)
    }
    
    init(collectionVariable: CollectionVariable<T>,
         shouldWriteInCollectionVariable: Bool,
         tabNavigator: TabNavigator?,
         notificationsManager: NotificationsManager = LGNotificationsManager.sharedInstance,
         tracker: Tracker = TrackerProxy.sharedInstance,
         chatRepository: ChatRepository = Core.chatRepository,
         featureFlags: FeatureFlags = FeatureFlags.sharedInstance) {
        self.objects = collectionVariable
        self.shouldWriteInCollectionVariable = shouldWriteInCollectionVariable
        self.status = .loading
        self.tabNavigator = tabNavigator
        self.notificationsManager = notificationsManager
        self.tracker = tracker
        self.chatRepository = chatRepository
        self.featureFlags = featureFlags
        super.init()
        
        self.multipageRequester = MultiPageRequester() { [weak self] (page, completion) in
            self?.index(page, completion: completion)
        }
        setupRx()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        inactiveDisposeBag = DisposeBag()
        
        if shouldScrollToTopVar.value {
            shouldScrollToTopVar.value = false
        }
    }
    
    override func didBecomeInactive() {
        super.didBecomeInactive()
        setupInactiveRx()
    }


    // MARK: - Public methods

    func openInactiveConversations() {
        tracker.trackEvent(TrackerEvent.chatViewInactiveConversations())
        tabNavigator?.openChat(.inactiveConversations, source: .chatList, predefinedMessage: nil)
    }
    
    func objectAtIndex(_ index: Int) -> T? {
        guard index < objects.value.count else { return nil }
        return objects.value[index]
    }

    func clear() {
        updateObjects(newObjects: [])
        nextPage = 1
        isLastPage = false
        isLoading = false
    }

    func selectedObjectsAtIndexes(_ indexes: [Int]) -> [T]? {
        return indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap { objects.value[$0] }
    }

    func index(_ page: Int, completion: ((Result<[T], RepositoryError>) -> ())?) {
        // Must be implemented in subclasses
    }

    func didFinishLoading() {
        notificationsManager.updateChatCounters()
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


    // MARK: - ChatGroupedListViewModelType

    func refresh(completion: (() -> Void)?) {
        guard canRetrieve else { return }
        if objectCount == 0 {
            retrievePage(firstPage, completion: completion)
        } else {
            reloadCurrentPagesWith(completion: completion)
        }
    }


    // MARK: - Paginable

    func retrievePage(_ page: Int) {
        retrievePage(page, completion: nil)
    }
    
    func retrievePage(_ page: Int, completion: (() -> Void)?) {
        let firstPage = (page == 1)
        isLoading = true
        var hasToRetrieveFirstPage: Bool = false
        chatGroupedDelegate?.chatGroupedListViewModelDidStartRetrievingObjectList()
        
        index(page) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                
                if firstPage {
                    strongSelf.shouldRefreshConversationsTabTrigger = false
                    strongSelf.updateObjects(newObjects: value)
                } else {
                    strongSelf.updateObjects(newObjects: strongSelf.objects.value + value)
                }
                
                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1
                
                if let emptyVM = strongSelf.emptyStatusViewModel, firstPage && strongSelf.objectCount == 0 {
                    strongSelf.status = .empty(emptyVM)
                } else {
                    strongSelf.status = .data
                }
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(page)
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
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(page)
            }
            strongSelf.isLoading = false
            if hasToRetrieveFirstPage {
                strongSelf.retrieveFirstPage()
            }
            completion?()
        }
        didFinishLoading()
    }


    // MARK: - Private methods

    private func reloadCurrentPagesWith(completion: (() -> ())?) {
        guard firstPage < nextPage else {
            completion?()
            return
        }

        isLoading = true
        chatGroupedDelegate?.chatGroupedListViewModelDidStartRetrievingObjectList()

        let pages: [Int] = Array(firstPage..<nextPage)
        multipageRequester?.request(pages: pages) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false

            if let reloadedData = result.value {
                if let emptyVM = strongSelf.emptyStatusViewModel, reloadedData.isEmpty {
                    strongSelf.status = .empty(emptyVM)
                } else {
                    strongSelf.status = .data
                }
                strongSelf.updateObjects(newObjects: reloadedData)
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(strongSelf.nextPage)
            } else if let error = result.error {
                if let emptyVM = strongSelf.emptyViewModelForError(error) {
                    strongSelf.status = .error(emptyVM)
                } else {
                    strongSelf.retrieveFirstPage()
                }

                strongSelf.updateObjects(newObjects: [])
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(strongSelf.nextPage)
            }

            strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
            strongSelf.didFinishLoading()

            completion?()
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
    
    private func updateObjects(newObjects: [T]) {
        guard !shouldWriteInCollectionVariable else { return }
        objects.replaceAll(with: newObjects)
    }
}


// MARK: - Rx

fileprivate extension BaseChatGroupedListViewModel {
    func setupRx() {
        objects.observable.map { messages in
            return messages.count
        }.bind(to: rx_objectCount).disposed(by: disposeBag)
        
        editing.asObservable().subscribeNext { [weak self] editing in
            self?.chatGroupedDelegate?.chatGroupedListViewModelSetEditing(editing)
        }.disposed(by: disposeBag)
        
        if shouldWriteInCollectionVariable {
            objects.changesObservable.subscribeNext { [weak self] _ in
                self?.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                self?.notificationsManager.updateChatCounters()
            }.disposed(by: disposeBag)
        }
        
        chatRepository.inactiveConversationsCount.asObservable().bind(to: inactiveConversationsCount).disposed(by: disposeBag)
    }
    
    func setupInactiveRx() {
        let isFirstObjectUpdated = objects.changesObservable.map { change -> Bool in
            let index: Int?
            switch change {
            case let .insert(atIndex, _):
                index = atIndex
            case let .swap(_, toIndex, _):
                index = toIndex
            case let .move(_, toIndex, _):
                index = toIndex
            case .remove, .composite:
                index = nil
            }
            
            return index == 0
        }
        isFirstObjectUpdated.distinctUntilChanged().bind(to: shouldScrollToTopVar).disposed(by: inactiveDisposeBag)
    }
}


// MARK: - Tracking

fileprivate extension BaseChatGroupedListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason, errorCode: Int?) {
        let event = TrackerEvent.emptyStateVisit(typePage: .chatList, reason: reason, errorCode: errorCode)
        tracker.trackEvent(event)
    }
}
