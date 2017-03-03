//
//  ProductCarouselViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 24/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGo
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ProductCarouselViewModelSpec: BaseViewModelSpec {

    var showOnboardingCalled: Bool?
    var removeMoreInfoTooltipCalled: Bool?

    var lastBuyersToRate: [UserProduct]?
    var buyerToRateResult: String?
    var shownAlertText: String?
    var shownFavoriteBubble: Bool?

    override func spec() {
        var sut: ProductCarouselViewModel!

        var productViewModelMaker: MockProductViewModelMaker!
        var productListRequester: MockProductListRequester!
        var keyValueStorage: MockKeyValueStorage!
        var imageDownloader: MockImageDownloader!

        var myUserRepository: MockMyUserRepository!
        var productRepository: MockProductRepository!
        var commercializerRepository: MockCommercializerRepository!
        var chatWrapper: MockChatWrapper!
        var locationManager: MockLocationManager!
        var countryHelper: CountryHelper!
        var product: MockProduct!
        var featureFlags: MockFeatureFlags!
        var purchasesShopper: MockPurchasesShopper!
        var notificationsManager: MockNotificationsManager!
        var monetizationRepository: MockMonetizationRepository!
        var tracker: MockTracker!

        var disposeBag: DisposeBag!

        var cellModelsObserver: TestableObserver<[ProductCarouselCellModel]>!
        var productInfoObserver: TestableObserver<ProductVMProductInfo?>!
        var productImageUrlsObserver: TestableObserver<[URL]>!
        var userInfoObserver: TestableObserver<ProductVMUserInfo?>!
        var productStatsObserver: TestableObserver<ProductStats?>!
        var navBarButtonsObserver: TestableObserver<[UIAction]>!
        var actionButtonsObserver: TestableObserver<[UIAction]>!
        var statusObserver: TestableObserver<ProductViewModelStatus>!
        var isFeaturedObserver: TestableObserver<Bool>!
        var quickAnswersObserver: TestableObserver<[QuickAnswer]>!
        var quickAnswersAvailableObserver: TestableObserver<Bool>!
        var quickAnswersCollapsedObserver: TestableObserver<Bool>!
        var directChatEnabledObserver: TestableObserver<Bool>!
        var directChatPlaceholderObserver: TestableObserver<String>!
        var directChatMessagesObserver: TestableObserver<[ChatViewMessage]>!
        var editButtonStateObserver: TestableObserver<ButtonState>!
        var isFavoriteObserver: TestableObserver<Bool>!
        var favoriteButtonStateObserver: TestableObserver<ButtonState>!
        var shareButtonStateObserver: TestableObserver<ButtonState>!
        var bumpUpBannerInfoObserver: TestableObserver<BumpUpInfo?>!
        var socialMessageObserver: TestableObserver<SocialMessage?>!
        var socialSharerObserver: TestableObserver<SocialSharer>!

        fdescribe("ProductCarouselViewModelSpec") {

            func buildSut(productListModels: [ProductCellModel]?,
                          initialProduct: Product?,
                          source: EventParameterProductVisitSource,
                          showKeyboardOnFirstAppearIfNeeded: Bool,
                          trackingIndex: Int?,
                          firstProductSyncRequired: Bool) {

                sut = ProductCarouselViewModel(productListModels: productListModels,
                                               initialProduct: initialProduct,
                                               thumbnailImage: nil,
                                               productListRequester: productListRequester,
                                               source: source,
                                               showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded,
                                               trackingIndex: trackingIndex,
                                               firstProductSyncRequired: firstProductSyncRequired,
                                               featureFlags: featureFlags,
                                               keyValueStorage: keyValueStorage,
                                               imageDownloader: imageDownloader,
                                               productViewModelMaker: productViewModelMaker)
                sut.delegate = self
                sut.navigator = self

                disposeBag = DisposeBag()
                sut.objects.observable.bindTo(cellModelsObserver).addDisposableTo(disposeBag)
                sut.productInfo.asObservable().bindTo(productInfoObserver).addDisposableTo(disposeBag)
                sut.productImageURLs.asObservable().bindTo(productImageUrlsObserver).addDisposableTo(disposeBag)
                sut.userInfo.asObservable().bindTo(userInfoObserver).addDisposableTo(disposeBag)
                sut.productStats.asObservable().bindTo(productStatsObserver).addDisposableTo(disposeBag)
                sut.navBarButtons.asObservable().bindTo(navBarButtonsObserver).addDisposableTo(disposeBag)
                sut.actionButtons.asObservable().bindTo(actionButtonsObserver).addDisposableTo(disposeBag)
                sut.status.asObservable().bindTo(statusObserver).addDisposableTo(disposeBag)
                sut.isFeatured.asObservable().bindTo(isFeaturedObserver).addDisposableTo(disposeBag)
                sut.quickAnswers.asObservable().bindTo(quickAnswersObserver).addDisposableTo(disposeBag)
                sut.quickAnswersAvailable.asObservable().bindTo(quickAnswersAvailableObserver).addDisposableTo(disposeBag)
                sut.quickAnswersCollapsed.asObservable().bindTo(quickAnswersCollapsedObserver).addDisposableTo(disposeBag)
                sut.directChatEnabled.asObservable().bindTo(directChatEnabledObserver).addDisposableTo(disposeBag)
                sut.directChatPlaceholder.asObservable().bindTo(directChatPlaceholderObserver).addDisposableTo(disposeBag)
                sut.directChatMessages.observable.bindTo(directChatMessagesObserver).addDisposableTo(disposeBag)
                sut.editButtonState.asObservable().bindTo(editButtonStateObserver).addDisposableTo(disposeBag)
                sut.isFavorite.asObservable().bindTo(isFavoriteObserver).addDisposableTo(disposeBag)
                sut.favoriteButtonState.asObservable().bindTo(favoriteButtonStateObserver).addDisposableTo(disposeBag)
                sut.shareButtonState.asObservable().bindTo(shareButtonStateObserver).addDisposableTo(disposeBag)
                sut.bumpUpBannerInfo.asObservable().bindTo(bumpUpBannerInfoObserver).addDisposableTo(disposeBag)
                sut.socialMessage.asObservable().bindTo(socialMessageObserver).addDisposableTo(disposeBag)
                sut.socialSharer.asObservable().bindTo(socialSharerObserver).addDisposableTo(disposeBag)
            }

            beforeEach {
                myUserRepository = MockMyUserRepository()
                productRepository = MockProductRepository()
                commercializerRepository = MockCommercializerRepository()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct.makeMock()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository()
                tracker = MockTracker()

                productListRequester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                keyValueStorage = MockKeyValueStorage()
                imageDownloader = MockImageDownloader()

                productViewModelMaker = MockProductViewModelMaker(myUserRepository: myUserRepository,
                                                                  productRepository: productRepository,
                                                                  commercializerRepository: commercializerRepository,
                                                                  chatWrapper: chatWrapper,
                                                                  locationManager: locationManager,
                                                                  countryHelper: countryHelper,
                                                                  featureFlags: featureFlags,
                                                                  purchasesShopper: purchasesShopper,
                                                                  notificationsManager: notificationsManager,
                                                                  monetizationRepository: monetizationRepository,
                                                                  tracker: tracker)

                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                cellModelsObserver = scheduler.createObserver(Array<ProductCarouselCellModel>.self)
                productInfoObserver = scheduler.createObserver(Optional<ProductVMProductInfo>.self)
                productImageUrlsObserver = scheduler.createObserver(Array<URL>.self)
                userInfoObserver = scheduler.createObserver(Optional<ProductVMUserInfo>.self)
                productStatsObserver = scheduler.createObserver(Optional<ProductStats>.self)
                navBarButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                actionButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                statusObserver = scheduler.createObserver(ProductViewModelStatus.self)
                isFeaturedObserver = scheduler.createObserver(Bool.self)
                quickAnswersObserver = scheduler.createObserver(Array<QuickAnswer>.self)
                quickAnswersAvailableObserver = scheduler.createObserver(Bool.self)
                quickAnswersCollapsedObserver = scheduler.createObserver(Bool.self)
                directChatEnabledObserver = scheduler.createObserver(Bool.self)
                directChatPlaceholderObserver = scheduler.createObserver(String.self)
                directChatMessagesObserver = scheduler.createObserver(Array<ChatViewMessage>.self)
                editButtonStateObserver = scheduler.createObserver(ButtonState.self)
                isFavoriteObserver = scheduler.createObserver(Bool.self)
                favoriteButtonStateObserver = scheduler.createObserver(ButtonState.self)
                shareButtonStateObserver = scheduler.createObserver(ButtonState.self)
                bumpUpBannerInfoObserver = scheduler.createObserver(Optional<BumpUpInfo>.self)
                socialMessageObserver = scheduler.createObserver(Optional<SocialMessage>.self)
                socialSharerObserver = scheduler.createObserver(SocialSharer.self)

                self.resetViewModelSpec()
            }
            describe("onboarding") {
                context("didn't show onboarding previously") {
                    beforeEach {
                        let product = MockProduct.makeMock()
                        keyValueStorage[.didShowProductDetailOnboarding] = false
                        buildSut(productListModels: nil,
                                 initialProduct: product,
                                 source: .productList,
                                 showKeyboardOnFirstAppearIfNeeded: false,
                                 trackingIndex: nil,
                                 firstProductSyncRequired: false)
                        sut.active = true
                    }
                    it("calls show onboarding") {
                        expect(self.showOnboardingCalled).to(beTrue())
                    }
                }
                context("didn't show onboarding previously") {
                    beforeEach {
                        let product = MockProduct.makeMock()
                        keyValueStorage[.didShowProductDetailOnboarding] = true
                        buildSut(productListModels: nil,
                                 initialProduct: product,
                                 source: .productList,
                                 showKeyboardOnFirstAppearIfNeeded: false,
                                 trackingIndex: nil,
                                 firstProductSyncRequired: false)
                        sut.active = true
                    }
                    it("doesn't call show onboarding") {
                        expect(self.showOnboardingCalled).to(beNil())
                    }
                }
            }
            describe("more info tooltip") {
                context("was never closed before") {
                    beforeEach {
                        let product = MockProduct.makeMock()
                        keyValueStorage[.productMoreInfoTooltipDismissed] = false
                        buildSut(productListModels: nil,
                                 initialProduct: product,
                                 source: .productList,
                                 showKeyboardOnFirstAppearIfNeeded: false,
                                 trackingIndex: nil,
                                 firstProductSyncRequired: false)
                        sut.active = true
                    }
                    it("shouldShowMoreInfoTooltip is true") {
                        expect(sut.shouldShowMoreInfoTooltip) == true
                    }
                    describe("more info opens") {
                        beforeEach {
                            sut.moreInfoState.value = .shown
                        }
                        it("shouldShowMoreInfoTooltip is false") {
                            expect(sut.shouldShowMoreInfoTooltip) == false
                        }
                        it("calls to hide more info tooltip") {
                            expect(self.removeMoreInfoTooltipCalled) == true
                        }
                    }
                }
                context("was closed before") {
                    beforeEach {
                        let product = MockProduct.makeMock()
                        keyValueStorage[.productMoreInfoTooltipDismissed] = true
                        buildSut(productListModels: nil,
                                 initialProduct: product,
                                 source: .productList,
                                 showKeyboardOnFirstAppearIfNeeded: false,
                                 trackingIndex: nil,
                                 firstProductSyncRequired: false)
                        sut.active = true
                    }
                    it("shouldShowMoreInfoTooltip is false") {
                        expect(sut.shouldShowMoreInfoTooltip) == false
                    }
                }
            }
            describe("show more info") {
                var product: Product!
                beforeEach {
                    product = MockProduct.makeMock()
                    buildSut(productListModels: nil,
                             initialProduct: product,
                             source: .productList,
                             showKeyboardOnFirstAppearIfNeeded: false,
                             trackingIndex: nil,
                             firstProductSyncRequired: false)
                    sut.active = true
                    sut.moreInfoState.value = .shown
                }
                it("tracks more info visit") {
                    expect(tracker.trackedEvents.last?.actualName) == "product-detail-visit-more-info"
                }
                it("tracks more info visit with product Id same as provided") {
                    let firstEvent = tracker.trackedEvents.last
                    expect(firstEvent?.params?.stringKeyParams["product-id"] as? String) == product.objectId
                }
            }
        }
    }

    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        lastBuyersToRate = nil
        buyerToRateResult = nil
        shownAlertText = nil

        showOnboardingCalled = nil
        removeMoreInfoTooltipCalled = nil
    }

    override func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        shownAlertText = message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            actions.last?.action()
        }
    }
}


extension ProductCarouselViewModelSpec: ProductCarouselViewModelDelegate {
    func vmRemoveMoreInfoTooltip() {
        removeMoreInfoTooltipCalled = true
    }
    func vmShowOnboarding() {
        showOnboardingCalled = true
    }

    // Forward from ProductViewModelDelegate
    func vmOpenPromoteProduct(_ promoteVM: PromoteProductViewModel) {}
    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel) {}
    func vmAskForRating() {}
    func vmShowCarouselOptions(_ cancelLabel: String, actions: [UIAction]) {}
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (UIViewController(), nil)
    }
    func vmResetBumpUpBannerCountdown() {}
}

extension ProductCarouselViewModelSpec: ProductDetailNavigator {
    func closeProductDetail() {

    }
    func editProduct(_ product: Product) {

    }
    func openProductChat(_ product: Product) {

    }
    func closeAfterDelete() {

    }
    func openFreeBumpUpForProduct(product: Product, socialMessage: SocialMessage, withPaymentItemId: String) {

    }
    func openPayBumpUpForProduct(product: Product, purchaseableProduct: PurchaseableProduct) {

    }
    func selectBuyerToRate(source: RateUserSource, buyers: [UserProduct], completion: @escaping (String?) -> Void) {
        let result = self.buyerToRateResult
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion(result)
            self.lastBuyersToRate = buyers
        }
    }
    func showProductFavoriteBubble(with data: BubbleNotificationData) {
        shownFavoriteBubble = true
    }
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue,
                                            loggedInAction: @escaping (() -> Void)) {
        loggedInAction()
    }
}
