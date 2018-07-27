import Foundation
import LGCoreKit
import LGComponents

final class UserCoordinator {
    private let navigationController: UINavigationController
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository

    private lazy var listingCoordinator = ListingCoordinator(navigationController: navigationController)

    convenience init(navigationController: UINavigationController){
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

    func openUser(userId: String, source: UserSource) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user, source: source)
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

    func openUser(user: User, source: UserSource) {
        // If it's me do not then open the user profile
        guard myUserRepository.myUser?.objectId != user.objectId else { return }

        let vm = UserProfileViewModel.makePublicProfile(user: user, source: source)
        vm.navigator = self
        let vc = UserProfileViewController(viewModel: vm, hidesBottomBarWhenPushed: false)
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
    func openUserReport(source: EventParameterTypePage, userReportedId: String) {
        let vm = ReportUsersViewModel(origin: source, userReportedId: userReportedId)
        let vc = ReportUsersViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
}
