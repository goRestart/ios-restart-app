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
    func vmReloadProductList()
}

enum UserViewControllerTab {
    case Selling, Sold, Favorites

    var title: String {
        switch self {
        case .Selling:
            return LGLocalizedString.profileSellingProductsTab
        case .Sold:
            return LGLocalizedString.profileSoldProductsTab
        case .Favorites:
            return LGLocalizedString.profileFavouritesProductsTab
        }
    }

    // TODO: 🌶 Refactor
    var profileProductListViewType: ProfileProductListViewType? {
        switch self {
        case .Selling:
            return .Selling
        case .Sold:
            return .Sold
        case .Favorites:
            return nil
        }
    }
}

class UserViewModel: BaseViewModel {

    private static let userBgEffectAlphaMax: CGFloat = 0.9
    private static let userBgTintAlphaMax: CGFloat = 0.54

    let myUserRepository: MyUserRepository
    let userRepository: UserRepository
    let productRepository: ProductRepository
    let tracker: Tracker

    let user: Variable<User?>
    private let userRelation = Variable<UserUserRelation?>(nil)

    let source: UserProfileSource

    // Input
    let tab = Variable<UserViewControllerTab>(.Selling)

    // Output
    let backgroundColor = Variable<UIColor>(UIColor.clearColor())
    let userStatus = Variable<ChatInfoViewStatus>(.Available)
    let userAvatarPlaceholder = Variable<UIImage?>(nil)
    let userAvatarURL = Variable<NSURL?>(nil)
    let userId = Variable<String?>(nil)
    let userName = Variable<String?>(nil)
    let userLocation = Variable<String?>(nil)

//    let tabs = Variable<[UserViewControllerTab]>([])

//        didSet {
//
//        }
//    }
    weak var userProductListViewModel: ProfileProductListViewModel? {
        didSet {
            userProductListViewModel?.user = user.value
            // TODO: 🌶 Incl. favorites so it won't be nilable
            if let type = tab.value.profileProductListViewType {
                userProductListViewModel?.type = type
            }
        }
    }

    weak var delegate: UserViewModelDelegate?

    let disposeBag: DisposeBag


    // MARK: - Lifecycle

    convenience init(source: UserProfileSource) {
        let myUserRepository = Core.myUserRepository
        self.init(user: myUserRepository.myUser, source: source)
    }

    convenience init(user: User?, source: UserProfileSource) {
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, userRepository: userRepository, productRepository: productRepository, tracker: tracker, user: user, source: source)
    }

    init(myUserRepository: MyUserRepository, userRepository: UserRepository, productRepository: ProductRepository, tracker: Tracker, user: User?, source: UserProfileSource) {
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.productRepository = productRepository
        self.tracker = tracker
        self.user = Variable<User?>(user)
        self.source = source
        self.disposeBag = DisposeBag()
        super.init()

        setupRxBindings()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        guard itsMe else { return }
        updateWithMyUser()
    }
}


// MARK: - Public methods

extension UserViewModel {


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

    private func updateWithMyUser() {
        guard let myUser = myUserRepository.myUser else { return }
        user.value = myUser
    }

    private func productListViewModelForTab(tab: UserViewControllerTab) -> ProfileProductListViewModel {
        return ProfileProductListViewModel(user: user.value, type: tab.profileProductListViewType)
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

            if strongSelf.itsMe {
                strongSelf.backgroundColor.value = StyleHelper.avatarColorForString(user?.objectId)
            } else {
                strongSelf.backgroundColor.value = StyleHelper.backgroundColorForString(user?.objectId)
            }
            strongSelf.userAvatarPlaceholder.value = LetgoAvatar.avatarWithID(user?.objectId, name: user?.name)
            strongSelf.userAvatarURL.value = user?.avatar?.fileURL
            strongSelf.userId.value = user?.objectId
            strongSelf.userName.value = user?.name
            strongSelf.userLocation.value = user?.postalAddress.cityCountryString

//            if strongSelf.itsMe {
//                strongSelf.tabs.value = [.Selling, .Sold, .Favorites]
//            } else {
//                strongSelf.tabs.value = [.Selling, .Sold]
//            }

        }.addDisposableTo(disposeBag)

        user.asObservable().subscribeNext { [weak self] user in
            self?.userRelation.value = nil
            self?.retrieveUsersRelation()
        }.addDisposableTo(disposeBag)

        user.asObservable().subscribeNext { [weak self] user in
            self?.userProductListViewModel?.user = user
        }.addDisposableTo(disposeBag)

//        tab.asObservable().subscribeNext { [weak self] user in
//            self?.userProductListViewModel?.user = user
//        }.addDisposableTo(disposeBag)

//        tabs.asObservable().subscribeNext { [weak self] tabs in
//            self?.productListViewModels = tabs.flatMap { self?.productListViewModelForTab($0) }
//        }.addDisposableTo(disposeBag)

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
