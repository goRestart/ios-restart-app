@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble
import LGComponents

class ListingDeckViewModelBinderSpec: QuickSpec {

    override func spec() {
        var sut: ListingDeckViewModelBinder!
        var listingDeckViewModel: ListingDeckViewModelType!
        var listing: Listing!

        var listingViewModelMaker: MockListingViewModelMaker!

        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!

        var actionButtonsObserver: TestableObserver<[UIAction]>!
        var quickAnswersObserver: TestableObserver<[QuickAnswer]>!
        var chatEnabled: TestableObserver<Bool>!
        var directChatPlaceholderObserver: TestableObserver<String>!
        var bumpUpBannerInfoObserver: TestableObserver<BumpUpInfo?>!

        describe("ListingDeckViewModelBinderSpec") {
            beforeEach {
                sut = ListingDeckViewModelBinder()
                var productMock = MockProduct.makeMock()
                productMock.status = .approved
                listing = .product(productMock)

                listingViewModelMaker = MockListingViewModelMaker(myUserRepository: MockMyUserRepository(),
                                                                  userRepository: MockUserRepository(),
                                                                  listingRepository: MockListingRepository(),
                                                                  chatWrapper: MockChatWrapper(),
                                                                  locationManager: MockLocationManager(),
                                                                  countryHelper: CountryHelper.mock(),
                                                                  featureFlags: MockFeatureFlags(),
                                                                  purchasesShopper: MockPurchasesShopper(),
                                                                  monetizationRepository: MockMonetizationRepository(),
                                                                  tracker: MockTracker(),
                                                                  keyValueStorage: MockKeyValueStorage(),
                                                                  reputationTooltipManager: MockReputationTooltipManager())

                listingDeckViewModel = MockListingDeckViewModelType()

                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()

                actionButtonsObserver = scheduler.createObserver([UIAction].self)
                quickAnswersObserver = scheduler.createObserver([QuickAnswer].self)
                directChatPlaceholderObserver = scheduler.createObserver(String.self)
                chatEnabled = scheduler.createObserver(Bool.self)
                bumpUpBannerInfoObserver = scheduler.createObserver(BumpUpInfo?.self)

                disposeBag = DisposeBag()
                listingDeckViewModel.actionButtons.asObservable()
                    .observeOn(MainScheduler.instance)
                    .bind(to:actionButtonsObserver).disposed(by:disposeBag)
                listingDeckViewModel.quickChatViewModel.quickAnswers.asObservable()
                    .bind(to:quickAnswersObserver).disposed(by:disposeBag)
                listingDeckViewModel.quickChatViewModel.chatEnabled.asObservable()
                    .bind(to:chatEnabled).disposed(by:disposeBag)
                listingDeckViewModel.quickChatViewModel.directChatPlaceholder.asObservable()
                    .bind(to:directChatPlaceholderObserver).disposed(by:disposeBag)
                listingDeckViewModel.bumpUpBannerInfo.asObservable()
                    .bind(to:bumpUpBannerInfoObserver).disposed(by:disposeBag)

                sut.deckViewModel = listingDeckViewModel
                sut.bind(to: listingViewModelMaker.make(listing: listing, visitSource: .listingList),
                         quickChatViewModel: MockQuickChatViewModelRx())
            }

            afterEach {
                scheduler.stop()
                disposeBag = nil
            }

            context("after moving to the current viewmodel") {
                it("actionButtonsObserver changed") {
                    expect(actionButtonsObserver.eventValues.count).toEventually(beGreaterThan(0))
                }

                it("quickAnswersObserver changed") {
                    expect(quickAnswersObserver.eventValues.count).toEventually(beGreaterThan(0))
                }

                it("chatEnabled changed") {
                    expect(chatEnabled.eventValues.count).toEventually(beGreaterThan(0))
                }

                it("directChatPlaceholderObserver changed") {
                    expect(directChatPlaceholderObserver.eventValues.count).toEventually(beGreaterThan(0))
                }
                
                it("bumpUpBannerInfoObserver changed") {
                    expect(bumpUpBannerInfoObserver.eventValues.count).toEventually(beGreaterThan(0))
                }
            }
        }
    }
}

extension ListingDeckViewModelBinderSpec: ListingDetailNavigator {

    func openVideoPlayer(atIndex index: Int,
                         listingVM: ListingViewModel,
                         source: EventParameterListingVisitSource) { }
    func showUndoBubble(withMessage message: String, duration: TimeInterval, withAction action: @escaping () -> ()) { }

    func openListingChat(_ listing: Listing, source: EventParameterTypePage, interlocutor: User?) { }
    func openAskPhoneFor(listing: Listing, interlocutor: User?) { }
    func closeAskPhoneFor(listing: Listing,
                          openChat: Bool,
                          withPhoneNum: String?,
                          source: EventParameterTypePage,
                          interlocutor: User?) { }

    func editListing(_ listing: Listing,
                     bumpUpProductData: BumpUpProductData?,
                     listingCanBeBoosted: Bool,
                     timeSinceLastBump: TimeInterval?,
                     maxCountdown: TimeInterval) { }
    func openFreeBumpUp(forListing listing: Listing,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?,
                        maxCountdown: TimeInterval) { }

    func openPayBumpUp(forListing listing: Listing,
                       bumpUpProductData: BumpUpProductData,
                       typePage: EventParameterTypePage?,
                       maxCountdown: TimeInterval) { }
    func openBumpUpBoost(forListing listing: Listing,
                         bumpUpProductData: BumpUpProductData,
                         typePage: EventParameterTypePage?,
                         timeSinceLastBump: TimeInterval,
                         maxCountdown: TimeInterval) { }
    func openAppInvite(myUserId: String?, myUserName: String?) { }
    func openMostSearchedItems(source: PostingSource, enableSearch: Bool) {}
    func openHome() {}
    func openSell(source: PostingSource, postCategory: PostCategory?) {}
    func openAppRating(_ source: EventParameterRatingSource) {}
    func openUserRating(_ source: RateUserSource, data: RateUserData) {}
    func openUser(_ data: UserDetailData) {}
    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {}
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?) {}
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {}
    func openAppInvite() {}
    func canOpenAppInvite() -> Bool { return true }
    func openRatingList(_ userId: String) {}
    func closeProductDetail() {}
    func openListingChat(_ listing: Listing, source: EventParameterTypePage) {}
    func closeListingAfterDelete(_ listing: Listing) {}
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {}
    func showProductFavoriteBubble(with data: BubbleNotificationData) {}
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {}
    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {}
    func showBumpUpBoostSucceededAlert() {}
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {}
    func openFeaturedInfo() {}
    func closeFeaturedInfo() {}
    func openUserReport(source: EventParameterTypePage, userReportedId: String) {}
    func openUserVerificationView() {}
    func openListingReport(source: EventParameterTypePage, productId: String) {}
    func openListingAttributeTable(withViewModel viewModel: ListingAttributeTableViewModel) {}
    func closeListingAttributeTable() {}
}
