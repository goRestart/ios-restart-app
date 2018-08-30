import Foundation
import LGCoreKit
import LGComponents

final class UserWireframe {
    private let nc: UINavigationController
    private lazy var listingRouter = ListingWireframe(nc: nc)

    private let userAssembly: UserAssembly
    private let verificationAssembly: UserVerificationAssembly
    private let loginAssembly: LoginAssembly
    private let chatRouter: ChatWireframe

    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    
    convenience init(nc: UINavigationController){
        self.init(nc: nc,
                  userAssembly: LGUserBuilder.standard(nc),
                  verificationAssembly: LGUserVerificationBuilder.standard(nav: nc),
                  loginAssembly: LoginBuilder.modal,
                  chatRouter: ChatWireframe(nc: nc),
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository)
    }

    private init(nc: UINavigationController,
                 userAssembly: UserAssembly,
                 verificationAssembly: UserVerificationAssembly,
                 loginAssembly: LoginAssembly,
                 chatRouter: ChatWireframe,
                 userRepository: UserRepository,
                 myUserRepository: MyUserRepository) {
        self.nc = nc
        self.userAssembly = userAssembly
        self.verificationAssembly = verificationAssembly
        self.chatRouter = chatRouter
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.loginAssembly = loginAssembly
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
    
    func openListingChat(_ listing: Listing,
                         source: EventParameterTypePage,
                         interlocutor: User?,
                         openChatAutomaticMessage: ChatWrapperMessageType?) {
        chatRouter.openListingChat(listing,
                                   source: source,
                                   interlocutor: interlocutor,
                                   openChatAutomaticMessage: openChatAutomaticMessage)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingRouter.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }
    
    func openLogin(infoMessage: String, then loggedInAction: @escaping (() -> Void)) {
        let vc = loginAssembly.buildPopupSignUp(
            withMessage: R.Strings.productPostLoginMessage,
            andSource: .directChat,
            appearance: .light,
            loginAction: loggedInAction,
            cancelAction: nil
        )
        vc.modalTransitionStyle = .crossDissolve
        nc.present(vc, animated: true)
    }
    
    func openAskPhoneFor(listing: Listing, interlocutor: User?) {
        let assembly = ProfessionalDealerAskPhoneBuilder.modal(nc)
        let vc = assembly.buildProfessionalDealerAskPhone(listing: listing, interlocutor: interlocutor)
        nc.present(vc, animated: true, completion: nil)
    }
    
    func openListingChat(data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?) {
        chatRouter.openChat(data, source: source, predefinedMessage: predefinedMessage)
    }
}
