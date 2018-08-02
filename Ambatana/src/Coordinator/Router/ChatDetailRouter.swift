import Foundation
import LGCoreKit

protocol ChatDetailNavigator: DeepLinkNavigator {
    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
    func openUserVerificationView()
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?)
    func openUser(_ data: UserDetailData)
    func closeChatDetail()
    func openAppRating(_ source: EventParameterRatingSource)
    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool)
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo)
    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void))
    func openAssistantFor(listingId: String, dataDelegate: MeetingAssistantDataDelegate)
}

final class ChatDetailRouter: ChatDetailNavigator {
    private weak var navigationController: UINavigationController?
    private let deeplinkMailBox: DeepLinkMailBox
    private let chatAssembly: ChatAssembly
    private let verificationAssembly: UserVerificationAssembly

    convenience init(navigationController: UINavigationController) {
        self.init(navigationController: navigationController,
                  chatAssembly: LGChatBuilder.standard(nav: navigationController),
                  verificationAssembly: LGUserVerificationBuilder.standard(nav: navigationController),
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    init(navigationController: UINavigationController,
         chatAssembly: ChatAssembly,
         verificationAssembly: UserVerificationAssembly,
         deeplinkMailBox: DeepLinkMailBox) {
        self.navigationController = navigationController
        self.chatAssembly = chatAssembly
        self.verificationAssembly = verificationAssembly
        self.deeplinkMailBox = deeplinkMailBox
    }

    func navigate(with convertible: DeepLinkConvertible) {
        deeplinkMailBox.push(convertible: convertible)
    }

    func closeChatDetail() {
        navigationController?.popViewController(animated: true)
    }

    func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deeplinkMailBox.push(convertible: url)
    }

    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool) {
        let vc = chatAssembly.buildExpressChat(listings: listings,
                                               sourceProductId: sourceListingId,
                                               manualOpen: manualOpen)
        navigationController?.present(vc, animated: true)
    }

    func openUserVerificationView() {
        let vc = verificationAssembly.buildUserVerification()
        navigationController?.pushViewController(vc, animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        guard let nav = navigationController else { return }
        let listingCoordinator = ListingCoordinator(navigationController: nav)
        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }

    func openUser(_ data: UserDetailData) {
        guard let nav = navigationController else { return }
        let userCoordinator = UserCoordinator(navigationController: nav)
        userCoordinator.openUser(data)
    }

    func openVerifyAccounts(_ types: [VerificationType],
                            source: VerifyAccountsSource,
                            completionBlock: (() -> Void)?) {
        // TODO: This should be deleted so we won't implement it
        // https://ambatana.atlassian.net/browse/ABIOS-4661
    }

    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {
        let vc = chatAssembly.buildRateBuyers(source: source,
                                              buyers: buyers,
                                              listingId: listingId,
                                              sourceRateBuyers: sourceRateBuyers,
                                              trackingInfo: trackingInfo)
        navigationController?.pushViewController(vc, animated: true)
    }

    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue,
                                         loggedInAction: @escaping (() -> Void)) {

    }
    func openAssistantFor(listingId: String,
                          dataDelegate: MeetingAssistantDataDelegate) {

    }
}
