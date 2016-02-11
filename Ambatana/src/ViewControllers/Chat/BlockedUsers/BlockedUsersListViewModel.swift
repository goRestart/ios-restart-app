//
//  BlockedUsersListViewModel.swift
//  LetGo
//
//  Created by Dídac on 10/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

public protocol BlockedUsersListViewModelDelegate: class {
    func didStartRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, isFirstLoad: Bool, page: Int)
    func didFailRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, page: Int, error: ErrorData)
    func didSucceedRetrievingBlockedUsersList(viewModel: BlockedUsersListViewModel, page: Int, nonEmptyList: Bool)
}

public class BlockedUsersListViewModel: BaseViewModel, Paginable {

    var delegate: BlockedUsersListViewModelDelegate?
    var userRepository: UserRepository
    var blockedUsers: [User] = []


    // MARK: Paginable
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false

    var objectCount: Int {
        return blockedUsers.count
    }


    // MARK: - Lifecycle

    public init(userRepository: UserRepository, blockedUsers: [User]) {
        self.userRepository = userRepository
        self.blockedUsers = blockedUsers
        super.init()
    }

    public func clearBlockedUsersList() {
        blockedUsers = []
        nextPage = 1
        isLastPage = false
        isLoading = false
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
        delegate?.didStartRetrievingBlockedUsersList(self, isFirstLoad: blockedUsers.count < 1, page: page)
        
        userRepository.indexBlocked { [weak self] result in
            
            guard let strongSelf = self else { return }
            if let value = result.value {
                if page == 1 {
                    strongSelf.blockedUsers = value
                } else {
                    strongSelf.blockedUsers += value
                }

                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1
                strongSelf.delegate?.didSucceedRetrievingBlockedUsersList(strongSelf, page: page, nonEmptyList: !strongSelf.blockedUsers.isEmpty)
            } else let actualError = result.error {

                var errorData = ErrorData()
                switch actualError {
                case .Network:
                    errorData = strongSelf.networkError()
                case .Internal, .NotFound, .Unauthorized:
                    break
                }

                strongSelf.delegate?.didFailRetrievingBlockedUsersList(strongSelf, page: page, error: errorData)
            }
            strongSelf.isLoading = false
        }
    }
}
