import Foundation
import LGCoreKit
import LGComponents

final class UserWireframe {
    private let nc: UINavigationController
    private lazy var listingRouter = ListingWireframe(nc: nc)

    private let userAssembly: UserAssembly
    private let verificationAssembly: UserVerificationAssembly

    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    
    convenience init(nc: UINavigationController){
        self.init(nc: nc,
                  userAssembly: LGUserBuilder.standard(nc),
                  verificationAssembly: LGUserVerificationBuilder.standard(nav: nc),
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository)
    }

    private init(nc: UINavigationController,
                 userAssembly: UserAssembly,
                 verificationAssembly: UserVerificationAssembly,
                 userRepository: UserRepository,
                 myUserRepository: MyUserRepository) {
        self.nc = nc
        self.userAssembly = userAssembly
        self.verificationAssembly = verificationAssembly
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
    }

    func openUser(_ data: UserDetailData) {
        let hidesBottomBarWhenPushed = nc.viewControllers.count == 1
        switch data {
        case let .id(userId, source):
            openUser(userId: userId, source: source)
        case let .userAPI(user, source):
            openUser(user: user, source: source)
        case let .userChat(user):
            openUser(user, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        }
    }

    func openUser(userId: String, source: UserSource) {
        nc.showLoadingMessageAlert()
        userRepository.show(userId) { [weak self] result in
            if let user = result.value {
                self?.nc.dismissLoadingMessageAlert {
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
                self?.nc.dismissLoadingMessageAlert {
                    self?.nc.showAutoFadingOutMessageAlert(message: message)
                }
            }
        }
    }

    private func openUser(_ interlocutor: ChatInterlocutor) {
        let hidesBottomBarWhenPushed = nc.viewControllers.count == 1
        openUser(interlocutor, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
    }

    func openUser(user: User, source: UserSource) {
        // If it's me do not then open the user profile
        guard myUserRepository.myUser?.objectId != user.objectId else { return }
        let vc = userAssembly.buildUser(user: user, source: source)
        nc.pushViewController(vc, animated: true)
    }

    func openUser(_ interlocutor: ChatInterlocutor, hidesBottomBarWhenPushed: Bool) {
        let vc = userAssembly.buildUser(interlocutor: interlocutor, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        nc.pushViewController(vc, animated: true)
    }

    func openUserVerification() {
        let vc = verificationAssembly.buildUserVerification()
        nc.pushViewController(vc, animated: true)
    }
}

extension UserWireframe: PublicProfileNavigator {
    func openUserReport(source: EventParameterTypePage, userReportedId: String) {
        let vc = userAssembly.buildUserReport(source: source, userReportedId: userReportedId)
        nc.pushViewController(vc, animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingRouter.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }

    func openAvatarDetail(isPrivate: Bool, user: User) {
        let vc = userAssembly.buildUserAvatar(isPrivate: isPrivate, user: user)
        nc.pushViewController(vc, animated: true)
    }
}
