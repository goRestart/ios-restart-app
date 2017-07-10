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

protocol ChatGroupedListViewModel: class, RxPaginable, ChatGroupedListViewModelType {
    var chatGroupedDelegate: ChatGroupedListViewModelDelegate? { get set }
    var emptyStatusViewModel: LGEmptyViewModel? { get set }
    var activityIndicatorAnimating: Bool { get }
    var emptyViewModel: LGEmptyViewModel? { get }
    var emptyViewHidden: Bool { get }
    var tableViewHidden: Bool { get }
    func clear()
}

class BaseChatGroupedListViewModel<T>: BaseViewModel, ChatGroupedListViewModel {
    let objects: CollectionVariable<T>
    let shouldWriteInCollectionVariable: Bool
    let notificationsManager: NotificationsManager
    fileprivate let tracker: Tracker
    private(set) var status: ViewState {
        didSet {
            switch status {
            case .error:
                if let emptyReason = emptyViewModel?.emptyReason {
                    trackErrorStateShown(reason: emptyReason)
                }
                
            case .loading, .data, .empty:
                break
            }
        }
    }

    var emptyStatusViewModel: LGEmptyViewModel?

    weak var chatGroupedDelegate : ChatGroupedListViewModelDelegate?
    weak var tabNavigator: TabNavigator?

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

    private var multipageRequester: MultiPageRequester<T>?
    
    var shouldRefreshConversations: Bool = true

    
    // MARK: - Lifecycle

    convenience init(objects: [T],
                     tabNavigator: TabNavigator?,
                     notificationsManager: NotificationsManager = LGNotificationsManager.sharedInstance,
                     tracker: Tracker = TrackerProxy.sharedInstance) {
        self.init(collectionVariable: CollectionVariable(objects),
                  shouldWriteInCollectionVariable: false,
                  tabNavigator: tabNavigator,
                  notificationsManager: notificationsManager,
                  tracker: tracker)
    }
    
    init(collectionVariable: CollectionVariable<T>,
         shouldWriteInCollectionVariable: Bool,
         tabNavigator: TabNavigator?,
         notificationsManager: NotificationsManager = LGNotificationsManager.sharedInstance,
         tracker: Tracker = TrackerProxy.sharedInstance) {
        self.objects = collectionVariable
        self.shouldWriteInCollectionVariable = shouldWriteInCollectionVariable
        self.status = .loading
        self.tabNavigator = tabNavigator
        self.notificationsManager = notificationsManager
        self.tracker = tracker
        super.init()
        
        self.multipageRequester = MultiPageRequester() { [weak self] (page, completion) in
            self?.index(page, completion: completion)
        }
        setupPaginableRxBindings()
    }


    // MARK: - Public methods

    func objectAtIndex(_ index: Int) -> T? {
        guard index < objectCount else { return nil }
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
        if active {
            notificationsManager.updateChatCounters()
        }
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
        case let .network(_, onBackground):
            emptyVM = onBackground ? nil : LGEmptyViewModel.networkErrorWithRetry(retryAction)
        case .internalError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified, .serverError:
            emptyVM = LGEmptyViewModel.genericErrorWithRetry(retryAction)
        }
        return emptyVM
    }
    
    private func updateObjects(newObjects: [T]) {
        guard !shouldWriteInCollectionVariable else { return }
        objects.value = newObjects
    }
}


// MARK: - Rx

extension BaseChatGroupedListViewModel {
    fileprivate func setupPaginableRxBindings() {
        objects.observable.map { messages in
            return messages.count
        }.bindTo(rx_objectCount).addDisposableTo(disposeBag)
        
        editing.asObservable().subscribeNext { [weak self] editing in
            self?.chatGroupedDelegate?.chatGroupedListViewModelSetEditing(editing)
        }.addDisposableTo(disposeBag)
        
        if shouldWriteInCollectionVariable {
            objects.changesObservable.subscribeNext { [weak self] editing in
                self?.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
            }.addDisposableTo(disposeBag)
        }
    }
}


// MARK: - Tracking

fileprivate extension BaseChatGroupedListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason) {
        let event = TrackerEvent.emptyStateVisit(typePage: .chatList, reason: reason)
        tracker.trackEvent(event)
    }
}
