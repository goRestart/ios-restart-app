//
//  BlockedUsersListViewModel.swift
//  LetGo
//
//  Created by Dídac on 10/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result


protocol BlockedUsersListViewModelDelegate: class {
    func didStartUnblockingUsers(_ viewModel: BlockedUsersListViewModel)
    func didFailUnblockingUsers(_ viewModel: BlockedUsersListViewModel)
    func didSucceedUnblockingUsers(_ viewModel: BlockedUsersListViewModel)
}

class BlockedUsersListViewModel: BaseChatGroupedListViewModel<User> {

    weak var delegate: BlockedUsersListViewModelDelegate?
    private var userRepository: UserRepository


    // MARK: - Lifecycle

    convenience init() {
        self.init(userRepository: Core.userRepository, blockedUsers: [])
    }

    required init(userRepository: UserRepository, blockedUsers: [User]) {
        self.userRepository = userRepository
        super.init(collectionVariable: CollectionVariable(blockedUsers),
                   shouldWriteInCollectionVariable: false,
                   tabNavigator: nil)
    }


    // MARK: - Public methods
    // MARK: > Chats

    override func index(_ page: Int, completion: ((Result<[User], RepositoryError>) -> ())?) {
        super.index(page, completion: completion)
        userRepository.indexBlocked(completion)
    }


    // MARK: > Unblock

    func unblockSelectedUsersAtIndexes(_ indexes: [Int]) {
        guard let selectedUsers = selectedObjectsAtIndexes(indexes) else { return }
        let userIds = selectedUsers.flatMap {$0.objectId}
        trackUnblockUsers(userIds)
        delegate?.didStartUnblockingUsers(self)
        userRepository.unblockUsersWithIds(userIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.delegate?.didSucceedUnblockingUsers(strongSelf)
            } else if let _ = result.error {
                strongSelf.delegate?.didFailUnblockingUsers(strongSelf)
            }
        }
    }


    // MARK: - Tracking Methods

    private func trackUnblockUsers(_ userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chatList, unblockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
}