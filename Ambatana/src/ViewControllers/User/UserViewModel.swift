//
//  UserViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum UserProfileSource {
    case TabBar
    case ProductDetail
    case Chat
}

protocol UserViewModelDelegate: BaseViewModelDelegate {
}

class UserViewModel: BaseViewModel {
    // Constants
    private static let userBgEffectAlphaMax: CGFloat = 0.9
    private static let userBgTintAlphaMax: CGFloat = 0.54

    // Repositories / Managers
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let tracker: Tracker

    // Data & VMs
    private let user: Variable<User?>
    private(set) var isMyUser: Bool
    private let userRelation = Variable<UserUserRelation?>(nil)
    private let source: UserProfileSource

    private let sellingProductListViewModel: ProfileProductListViewModel
    private let soldProductListViewModel: ProfileProductListViewModel
    private let favoritesProductListViewModel: ProfileProductListViewModel

    // Input
    let tab = Variable<UserViewHeaderTab>(.Selling)

    // Output
    let backgroundColor = Variable<UIColor>(UIColor.clearColor())
    let headerMode = Variable<UserViewHeaderMode>(.MyUser)
    let userStatus = Variable<ChatInfoViewStatus>(.Available)
    let userAvatarPlaceholder = Variable<UIImage?>(nil)
    let userAvatarURL = Variable<NSURL?>(nil)
    let userId = Variable<String?>(nil)
    let userName = Variable<String?>(nil)
    let userLocation = Variable<String?>(nil)
    let productListViewModel: Variable<ProfileProductListViewModel>

    weak var delegate: UserViewModelDelegate?

    // Rx
    let disposeBag: DisposeBag


    // MARK: - Lifecycle

    static func myUserUserViewModel(source: UserProfileSource) -> UserViewModel {
        return UserViewModel(source: source)
    }

    private convenience init(source: UserProfileSource) {
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, userRepository: userRepository, tracker: tracker,
            isMyUser: true, user: nil, source: source)
    }

    convenience init(user: User, source: UserProfileSource) {
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, userRepository: userRepository, tracker: tracker,
            isMyUser: false, user: user, source: source)
    }

    init(myUserRepository: MyUserRepository, userRepository: UserRepository, tracker: Tracker, isMyUser: Bool,
        user: User?, source: UserProfileSource) {
            self.myUserRepository = myUserRepository
            self.userRepository = userRepository
            self.tracker = tracker
            self.isMyUser = isMyUser
            self.user = Variable<User?>(user)
            self.source = source
            self.sellingProductListViewModel = ProfileProductListViewModel(user: user, type: .Selling)
            self.soldProductListViewModel = ProfileProductListViewModel(user: user, type: .Sold)
            self.favoritesProductListViewModel = ProfileProductListViewModel(user: user, type: .Favorites)
            self.productListViewModel = Variable<ProfileProductListViewModel>(sellingProductListViewModel)
            self.disposeBag = DisposeBag()
            super.init()

            setupNotificationCenterObservers()
            setupRxBindings()
    }

    deinit {
        tearDownNotificationCenterObservers()
    }


    override func didBecomeActive() {
        super.didBecomeActive()
        guard isMyUser || itsMe else { return }
        updateWithMyUser()
    }
}


// MARK: - Private methods
// MARK: > Helpers

extension UserViewModel {
    private var itsMe: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        guard let userId = user.value?.objectId else { return false }
        return myUserId == userId
    }

    private func updateWithMyUser() {
        guard let myUser = myUserRepository.myUser else { return }
        user.value = myUser
    }
}


// MARK: > NSNotificationCenter

extension UserViewModel {
    private func setupNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("login:"),
            name: SessionManager.Notification.Login.rawValue, object: nil)
    }

    private func tearDownNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    dynamic private func login(notification: NSNotification) {
        updateWithMyUser()
    }
}



// MARK: > Requests

extension UserViewModel {
    private func retrieveUsersRelation() {
        guard let userId = user.value?.objectId else { return }
        guard !isMyUser else { return }

        userRepository.retrieveUserToUserRelation(userId) { [weak self] result in
            guard let userRelation = result.value else { return }
            self?.userRelation.value = userRelation
        }
    }
}


// MARK: - Rx

extension UserViewModel {
    private func setupRxBindings() {
        setupUserRxBindings()
        setupUserRelationRxBindings()
        setupTabRxBindings()
    }

    private func setupUserRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard let strongSelf = self else { return }

            if strongSelf.isMyUser {
                strongSelf.backgroundColor.value = StyleHelper.avatarColorForString(user?.objectId)
            } else {
                strongSelf.backgroundColor.value = StyleHelper.backgroundColorForString(user?.objectId)
            }
            strongSelf.userAvatarPlaceholder.value = LetgoAvatar.avatarWithID(user?.objectId, name: user?.name)
            strongSelf.userAvatarURL.value = user?.avatar?.fileURL
            strongSelf.userId.value = user?.objectId
            strongSelf.userName.value = user?.name
            strongSelf.userLocation.value = user?.postalAddress.cityCountryString

            strongSelf.headerMode.value = strongSelf.isMyUser ? .MyUser : .OtherUser
        }.addDisposableTo(disposeBag)

        user.asObservable().subscribeNext { [weak self] user in
            self?.userRelation.value = nil
            self?.retrieveUsersRelation()
        }.addDisposableTo(disposeBag)

        user.asObservable().subscribeNext { [weak self] user in
            self?.sellingProductListViewModel.user = user
            self?.soldProductListViewModel.user = user
            self?.favoritesProductListViewModel.user = user
        }.addDisposableTo(disposeBag)

        user.asObservable().subscribeNext { [weak self] user in
            guard let user = user else { return }
            self?.productListViewModel.value.user = user
        }.addDisposableTo(disposeBag)
    }

    private func setupUserRelationRxBindings() {
        userRelation.asObservable().map { [weak self] relation -> ChatInfoViewStatus in
            guard let relation = relation else { return .Available }
            guard let strongSelf = self where !strongSelf.isMyUser else { return .Available }

            if relation.isBlocked {
                return .Blocked
            } else if relation.isBlockedBy {
                return .BlockedBy
            } else {
                return .Available
            }
        }.bindTo(userStatus).addDisposableTo(disposeBag)
    }

    private func setupTabRxBindings() {
        tab.asObservable().map { [weak self] tab -> ProfileProductListViewModel? in
            switch tab {
            case .Selling:
                return self?.sellingProductListViewModel
            case .Sold:
                return self?.soldProductListViewModel
            case .Favorites:
                return self?.favoritesProductListViewModel
            }
        }.subscribeNext { [weak self] viewModel in
                guard let viewModel = viewModel else { return }
                self?.productListViewModel.value = viewModel

                switch viewModel.state {
                case .FirstLoadView:
                    viewModel.retrieveProducts()
                case .DataView, .ErrorView:
                    break
                }
        }.addDisposableTo(disposeBag)
    }
}
