//
//  UserViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol UserViewModelDelegate: BaseViewModelDelegate {
}

enum UserViewControllerTab {
    case Selling, Sold, Favorites
}

class UserViewModel: BaseViewModel {

    let myUserRepository: MyUserRepository
    let userRepository: UserRepository
    let productRepository: ProductRepository
    let tracker: Tracker

    let user: Variable<User?>
    private let userRelation = Variable<UserUserRelation?>(nil)

    let userStatus = Variable<ChatInfoViewStatus>(.Available)
    let userAvatarURL = Variable<NSURL?>(nil)
    let userName = Variable<String?>(nil)
    let userLocation = Variable<String?>(nil)
    let tabs = Variable<[UserViewControllerTab]>([])


    weak var delegate: UserViewModelDelegate?

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override convenience init() {
        let myUserRepository = Core.myUserRepository
        self.init(user: myUserRepository.myUser)
    }

    convenience init(user: User?) {
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, userRepository: userRepository, productRepository: productRepository, tracker: tracker, user: user)
    }

    init(myUserRepository: MyUserRepository, userRepository: UserRepository, productRepository: ProductRepository, tracker: Tracker, user: User?) {
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.productRepository = productRepository
        self.tracker = tracker
        self.user = Variable<User?>(user)
        super.init()

        setupRxBindings()
    }
}


// MARK: - Private methods
// MARK: > Helpers

extension UserViewModel {
    private var itsMe: Bool {
        guard let myUser = myUserRepository.myUser else { return false }
        guard let myUserId = myUser.objectId else { return false }
        guard let userId = user.value?.objectId else { return false }
        return myUserId == userId
    }
}


// MARK: > Requests

extension UserViewModel {
    private func retrieveUsersRelation() {
        guard let userId = user.value?.objectId else { return }
        guard !itsMe else { return }

        userRepository.retrieveUserToUserRelation(userId) { [weak self] result in
            guard let userRelation = result.value else { return }
            self?.userRelation.value = userRelation
        }
    }
}


// MARK: - Rx

extension UserViewModel {
    private func setupRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard let strongSelf = self else { return }

            strongSelf.userRelation.value = nil
            strongSelf.userAvatarURL.value = user?.avatar?.fileURL
            strongSelf.userName.value = user?.name
            strongSelf.userLocation.value = user?.postalAddress.cityCountryString

            if strongSelf.itsMe {
                strongSelf.tabs.value = [.Selling, .Sold, .Favorites]
            } else {
                strongSelf.tabs.value = [.Selling, .Sold]
            }

        }.addDisposableTo(disposeBag)

        user.asObservable().subscribeNext { [weak self] user in
            self?.retrieveUsersRelation()
        }.addDisposableTo(disposeBag)

        userRelation.asObservable().map { [weak self] relation -> ChatInfoViewStatus in
            guard let relation = relation else { return .Available }
            guard let strongSelf = self where !strongSelf.itsMe else { return .Available }

            if relation.isBlocked {
                return .Blocked
            } else if relation.isBlockedBy {
                return .BlockedBy
            } else {
                return .Available
            }
        }.bindTo(userStatus).addDisposableTo(disposeBag)
    }
}
