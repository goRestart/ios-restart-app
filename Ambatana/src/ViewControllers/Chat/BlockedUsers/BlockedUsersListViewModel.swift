//
//  BlockedUsersListViewModel.swift
//  LetGo
//
//  Created by Dídac on 10/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

enum BlockedUsersListStatus {
    case LoadingBlockedUsers
    case BlockedUsers
    case NoBlockedUsers(LGEmptyViewModel)
    case Error(LGEmptyViewModel)
}

protocol BlockedUsersListViewModelDelegate: class {

    func blockedUsersListViewModelShouldUpdateStatus(viewModel: BlockedUsersListViewModel)
    func blockedUsersListViewModel(viewModel: BlockedUsersListViewModel, setEditing editing: Bool, animated: Bool)

    func didStartRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel)
    func didFailRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, page: Int)
    func didSucceedRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, page: Int)
}

class BlockedUsersListViewModel: BaseViewModel, Paginable {

    var delegate: BlockedUsersListViewModelDelegate?
    var userRepository: UserRepository
    var blockedUsers: [User] = []

    private(set) var tab: ChatGroupedViewModel.Tab

    private(set) var status: BlockedUsersListStatus


    // MARK: Paginable
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false

    var objectCount: Int {
        return blockedUsers.count
    }


    // MARK: - Lifecycle

    convenience init(tab: ChatGroupedViewModel.Tab) {
        self.init(userRepository: Core.userRepository, blockedUsers: [], tab: tab)
    }

    required init(userRepository: UserRepository, blockedUsers: [User], tab: ChatGroupedViewModel.Tab) {
        self.tab = tab
        self.status = .LoadingBlockedUsers
        self.userRepository = userRepository
        self.blockedUsers = blockedUsers
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active && canRetrieve {
            if blockedUsers.isEmpty {
                retrieveFirstPage()
            } else {
                reloadCurrentPagesWithCompletion(nil)
            }
        }
    }

    func clearBlockedUsersList() {
        blockedUsers = []
        nextPage = 1
        isLastPage = false
        isLoading = false
    }

    func reloadCurrentPagesWithCompletion(completion: (() -> ())?) {

    }

    func blockedUserAtIndex(index: Int) -> User? {
        guard blockedUsers.count > index else { return nil }
        return blockedUsers[index]
    }


    // MARK: - Paginable

    internal func reloadCurrentPages() {

    }

    internal func retrievePage(page: Int) {
        print("retrieve page \(page)")

        isLoading = true
        delegate?.didStartRetrievingBlockedUsersList(self)

        delegate?.didSucceedRetrievingBlockedUsersList(self, page: page)

//        userRepository.indexBlocked { [weak self] result in
//            
//            guard let strongSelf = self else { return }
//            if let value = result.value {
//                if page == 1 {
//                    strongSelf.blockedUsers = value
//                } else {
//                    strongSelf.blockedUsers += value
//                }
//
//                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
//                strongSelf.nextPage = page + 1
//                strongSelf.delegate?.didSucceedRetrievingBlockedUsersList(strongSelf, page: page)
//            } else if let actualError = result.error {
//
//                var errorData = ErrorData()
//                switch actualError {
//                case .Network:
//                    errorData = strongSelf.networkError()
//                case .Internal, .NotFound, .Unauthorized:
//                    break
//                }
//
//                strongSelf.delegate?.didFailRetrievingBlockedUsersList(strongSelf, page: page)
//            }
//            strongSelf.isLoading = false
//        }
    }
}
