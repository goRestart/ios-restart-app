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

    fileprivate let objects: Variable<[T]>
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
        return objects.value.count
    }
    let rx_objectCount = Variable<Int>(0)
    let editing = Variable<Bool>(false)
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(objects: [T], tabNavigator: TabNavigator?, tracker: Tracker = TrackerProxy.sharedInstance) {
        self.objects = Variable<[T]>(objects)
        self.status = .loading
        self.tabNavigator = tabNavigator
        self.tracker = tracker
        super.init()

        setupPaginableRxBindings()
    }


    override func didBecomeActive(_ firstTime: Bool) {
        refresh(completion: nil)
    }


    // MARK: - Public methods

    func objectAtIndex(_ index: Int) -> T? {
        guard index < objectCount else { return nil }
        return objects.value[index]
    }

    func clear() {
        objects.value = []
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
        // Must be implemented in subclasses
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

    func reloadCurrentPagesWith(completion: (() -> ())?) {
        guard firstPage < nextPage else {
            completion?()
            return
        }

        isLoading = true
        chatGroupedDelegate?.chatGroupedListViewModelDidStartRetrievingObjectList()

        var reloadedObjects: [T] = []
        let chatReloadQueue = DispatchQueue(label: "ChatGroupedReloadQueue", attributes: [])

        // Request object pages serially
        var queueError: RepositoryError?
        chatReloadQueue.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            for page in strongSelf.firstPage..<strongSelf.nextPage {
                let result = synchronize({ completion in
                    self?.index(page, completion: { (result: Result<[T], RepositoryError>) -> () in
                        completion(result)
                    })
                    }, timeoutWith: Result<[T], RepositoryError>(error: RepositoryError.setupNetworkGenericError()))

                if let value = result.value {
                    reloadedObjects += value
                } else if let error = result.error {
                    // If an error is found do not request next pages
                    queueError = error
                    break
                }
            }

            strongSelf.isLoading = false

            DispatchQueue.main.async {
                // Status update
                if let error = queueError {
                    if let emptyVM = strongSelf.emptyViewModelForError(error) {
                        strongSelf.status = .error(emptyVM)
                    }
                    else {
                        strongSelf.retrieveFirstPage()
                    }
                } else if let emptyVM = strongSelf.emptyStatusViewModel, reloadedObjects.isEmpty {
                    strongSelf.status = .empty(emptyVM)
                } else {
                    strongSelf.status = .data
                }

                // Data update (if success) & delegate notification
                if let _ = queueError {
                    strongSelf.objects.value = []
                    strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(strongSelf.nextPage)
                } else {
                    strongSelf.objects.value = reloadedObjects
                    strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(strongSelf.nextPage)
                }

                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.didFinishLoading()

                completion?()
            }
            })
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
                    strongSelf.objects.value = value
                } else {
                    strongSelf.objects.value = strongSelf.objects.value + value
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
}


// MARK: - Rx

extension BaseChatGroupedListViewModel {
    fileprivate func setupPaginableRxBindings() {
        objects.asObservable().map { messages in
            return messages.count
            }.bindTo(rx_objectCount).addDisposableTo(disposeBag)
        
        editing.asObservable().subscribeNext { [weak self] editing in
            self?.chatGroupedDelegate?.chatGroupedListViewModelSetEditing(editing)
            }.addDisposableTo(disposeBag)
    }
}


// MARK: - Tracking

fileprivate extension BaseChatGroupedListViewModel {
    func trackErrorStateShown(reason: EventParameterEmptyReason) {
        let event = TrackerEvent.emptyStateVisit(typePage: .chatList, reason: reason)
        tracker.trackEvent(event)
    }
}
