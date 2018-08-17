import Foundation
import LGCoreKit
import LGComponents

final class UserCoordinator {
    private let navigationController: UINavigationController
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    
    weak var tabNavigator: TabNavigator?

    weak var listingCoordinator: ListingCoordinator?

    convenience init(navigationController: UINavigationController) {
        self.init(navigationController: navigationController,
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository)
    }

    private init(navigationController: UINavigationController,
                 userRepository: UserRepository,
                 myUserRepository: MyUserRepository) {
        self.navigationController = navigationController

        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
    }

    func openUser(_ data: UserDetailData) {
        switch data {
        case let .id(userId, source):
            openUser(userId: userId, source: source,
                     hidesBottomBarWhenPushed: navigationController.viewControllers.count == 1)
        case let .userAPI(user, source):
            openUser(user: user, source: source,
                     hidesBottomBarWhenPushed: navigationController.viewControllers.count == 1)
        case let .userChat(user):
            openUser(user, hidesBottomBarWhenPushed: navigationController.viewControllers.count == 1)
        }
    }

    func openUser(userId: String, source: UserSource, hidesBottomBarWhenPushed: Bool) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user, source: source, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = R.Strings.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError, .searchAlertError:
                    message = R.Strings.commonUserNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message: message)
                }
            }
        }
    }

    func openUser(user: User, source: UserSource, hidesBottomBarWhenPushed: Bool) {
        // If it's me do not then open the user profile
        guard myUserRepository.myUser?.objectId != user.objectId else { return }

        let vm = UserProfileViewModel.makePublicProfile(user: user, source: source)
        vm.navigator = self
        let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(_ interlocutor: ChatInterlocutor, hidesBottomBarWhenPushed: Bool) {
        let vm = UserProfileViewModel.makePublicProfile(chatInterlocutor: interlocutor, source: .chat)
        vm.navigator = self
        let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension UserCoordinator: PublicProfileNavigator {
    func openUserReport(source: EventParameterTypePage, userReportedId: String, rateData: RateUserData) {
        tabNavigator?.openUserReport(source: source, userReportedId: userReportedId, rateData: rateData)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingCoordinator?.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
}
