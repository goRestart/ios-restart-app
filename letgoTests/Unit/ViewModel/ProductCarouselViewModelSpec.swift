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

        var sessionManager: MockSessionManager!
        var myUserRepository: MockMyUserRepository!
        var productRepository: MockProductRepository!
        var commercializerRepository: MockCommercializerRepository!
        var stickersRepository: MockStickersRepository!
        var chatWrapper: MockChatWrapper!
        var locationManager: MockLocationManager!
        var countryHelper: CountryHelper!
        var product: MockProduct!
        var bubbleNotificationManager: MockBubbleNotificationManager!
        var featureFlags: MockFeatureFlags!
        var purchasesShopper: MockPurchasesShopper!
        var notificationsManager: MockNotificationsManager!
        var monetizationRepository: MockMonetizationRepository!
        var tracker: MockTracker!

        var disposeBag: DisposeBag!

        describe("ProductCarouselViewModelSpec") {

            func buildSut(productListModels: [ProductCellModel]?,
                          initialProduct: Product?,
                          source: EventParameterProductVisitSource,
                          showKeyboardOnFirstAppearIfNeeded: Bool,
                          trackingIndex: Int?) {

                sut = ProductCarouselViewModel(productListModels: productListModels,
                                               initialProduct: initialProduct,
                                               thumbnailImage: nil,
                                               productListRequester: productListRequester,
                                               source: source,
                                               showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded,
                                               trackingIndex: trackingIndex,
                                               featureFlags: featureFlags,
                                               keyValueStorage: keyValueStorage,
                                               imageDownloader: imageDownloader,
                                               productViewModelMaker: productViewModelMaker)
                sut.delegate = self
                sut.navigator = self

                disposeBag = DisposeBag()
            }

            beforeEach {
                sessionManager = MockSessionManager()
                myUserRepository = MockMyUserRepository()
                productRepository = MockProductRepository()
                commercializerRepository = MockCommercializerRepository()
                stickersRepository = MockStickersRepository()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct.makeMock()
                bubbleNotificationManager = MockBubbleNotificationManager()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository()
                tracker = MockTracker()

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

                self.resetViewModelSpec()
            }
        }
    }

    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        lastBuyersToRate = nil
        buyerToRateResult = nil
        shownAlertText = nil
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

    }
    func vmShowOnboarding() {

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
