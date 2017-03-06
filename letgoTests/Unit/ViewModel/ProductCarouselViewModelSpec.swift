//
//  ProductCarouselViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 24/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
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

        describe("ProductCarouselViewModelSpec") {

            func buildSut(productListModels: [ProductCellModel]? = nil,
                          initialProduct: Product? = nil,
                          source: EventParameterProductVisitSource = .productList,
                          showKeyboardOnFirstAppearIfNeeded: Bool = false,
                          trackingIndex: Int? = nil,
                          firstProductSyncRequired: Bool = false) {

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
                        keyValueStorage[.didShowProductDetailOnboarding] = false
                        buildSut(initialProduct: product)
                        sut.active = true
                    }
                    it("calls show onboarding") {
                        expect(self.showOnboardingCalled).to(beTrue())
                    }
                }
                context("didn't show onboarding previously") {
                    beforeEach {
                        keyValueStorage[.didShowProductDetailOnboarding] = true
                        buildSut(initialProduct: product)
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
                        keyValueStorage[.productMoreInfoTooltipDismissed] = false
                        buildSut(initialProduct: product)
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
                        keyValueStorage[.productMoreInfoTooltipDismissed] = true
                        buildSut(initialProduct: product)
                        sut.active = true
                    }
                    it("shouldShowMoreInfoTooltip is false") {
                        expect(sut.shouldShowMoreInfoTooltip) == false
                    }
                }
            }
            describe("show more info") {
                beforeEach {
                    buildSut(initialProduct: product)
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
            describe("quick answers") {
                describe("availability and quickAnswers list") {
                    context("product is mine and available") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                            var productUser = MockUserProduct.makeMock()
                            productUser.objectId = myUser.objectId
                            product.user = productUser
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                        }
                        it("quick answers are not available") {
                            expect(quickAnswersAvailableObserver.eventValues) == [false] //first product
                        }
                        it("quickAnswers are empty") {
                            expect(quickAnswersObserver.eventValues.map { $0.isEmpty }) == [true] //first product
                        }
                    }
                    context("product is not mine and available") {
                        context("non free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .normal(25)
                                buildSut(initialProduct: product)
                                sut.active = true
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("correct quick answers are present") {
                                let expectedAnswers: [QuickAnswer] = [.interested, .likeToBuy, .isNegotiable, .meetUp]
                                expect(quickAnswersObserver.eventValues.last?.map { $0.text }) == expectedAnswers.map { $0.text }
                            }
                        }
                        context("free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .free
                                featureFlags.freePostingModeAllowed = true
                                buildSut(initialProduct: product)
                                sut.active = true
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("correct quick answers are present") {
                                let expectedAnswers: [QuickAnswer] = [.interested, .meetUp, .productCondition]
                                expect(quickAnswersObserver.eventValues.last?.map { $0.text }) == expectedAnswers.map { $0.text }
                            }
                        }
                    }
                }
                describe("collapsed state") {
                    context("initial value non collapsed") {
                        beforeEach {
                            keyValueStorage[.productDetailQuickAnswersHidden] = false
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                        }
                        it("quickAnswersCollapsed is false") {
                            expect(quickAnswersCollapsedObserver.eventValues) == [false]
                        }
                        describe("close button/option is pressed") {
                            beforeEach {
                                sut.quickAnswersCloseButtonPressed()
                            }
                            it("quickAnswersCollapsed is now true") {
                                expect(quickAnswersCollapsedObserver.eventValues) == [false, true]
                            }
                            it("storage is now also true") {
                                expect(keyValueStorage[.productDetailQuickAnswersHidden]) == true
                            }
                        }
                    }
                    context("initial value collapsed") {
                        beforeEach {
                            keyValueStorage[.productDetailQuickAnswersHidden] = true
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                        }
                        it("quickAnswersCollapsed is true") {
                            expect(quickAnswersCollapsedObserver.eventValues) == [true]
                        }
                        describe("show option is pressed") {
                            beforeEach {
                                sut.quickAnswersShowButtonPressed()
                            }
                            it("quickAnswersCollapsed is now true") {
                                expect(quickAnswersCollapsedObserver.eventValues) == [true, false]
                            }
                            it("storage is now also true") {
                                expect(keyValueStorage[.productDetailQuickAnswersHidden]) == false
                            }
                        }
                    }
                }
            }
            describe("first product needs update") {
                var newProduct: MockProduct!
                beforeEach {
                    product.name = String.makeRandom()
                    newProduct = MockProduct.makeMock()
                    newProduct.name = String.makeRandom()
                    newProduct.objectId = product.objectId
                    newProduct.user = product.user
                    productRepository.productResult = ProductResult(newProduct)
                    buildSut(initialProduct: product, firstProductSyncRequired: true)
                }
                it("product info title passes trough both items title") {
                    expect(productInfoObserver.eventValues.flatMap { $0?.title }).toEventually(equal([product.title, newProduct.title].flatMap { $0 }))
                }
            }
            describe("pagination") {
                context("single item") {
                    beforeEach {
                        productListRequester.generateItems(30)
                        buildSut(initialProduct: product)
                    }
                    it("items count automatically becomes 21") {
                        expect(sut.objectCount).toEventually(equal(21))
                    }
                }
                context("multiple items") {
                    context("item before the threshold") {
                        beforeEach {
                            var products = MockProduct.makeMocks(count: 20)
                            products[0] = product
                            let productListModels = products.map { ProductCellModel.productCell(product: $0) }
                            productListRequester.generateItems(30)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            self.waitFor(timeout: 0.2)
                        }
                        it("doesn't paginate initially") {
                            expect(sut.objectCount).toNot(beGreaterThan(20))
                        }
                        describe("switch to item after threshold") {
                            beforeEach {
                                sut.moveToProductAtIndex(18, movement: .swipeRight)
                            }
                            it("gets one extra page") {
                                expect(sut.objectCount).toEventually(equal(40))
                            }
                        }
                    }
                    context("item after the threshold") {
                        beforeEach {
                            var products = MockProduct.makeMocks(count: 20)
                            products[18] = product
                            let productListModels = products.map { ProductCellModel.productCell(product: $0) }
                            productListRequester.generateItems(30)
                            buildSut(productListModels: productListModels, initialProduct: product)
                        }
                        it("paginates initially") {
                            expect(sut.objectCount).toEventually(equal(40))
                        }
                    }
                }
                context("long pagination") {
                    beforeEach {
                        //Simulating that we're on page 8-10
                        var products = MockProduct.makeMocks(count: 180)
                        products[160] = product
                        productListRequester.generateItems(200)
                        productListRequester.offset = 180
                        let productListModels = products.map { ProductCellModel.productCell(product: $0) }
                        buildSut(productListModels: productListModels, initialProduct: product)
                    }
                    describe("move to item before threshold") {
                        beforeEach {
                            sut.moveToProductAtIndex(172, movement: .swipeRight)
                            self.waitFor(timeout: 0.2)
                        }
                        it("doesn't paginate") {
                            expect(sut.objectCount).toNot(beGreaterThan(180))
                        }
                    }
                    describe("move to item after threshold") {
                        beforeEach {
                            sut.moveToProductAtIndex(178, movement: .swipeRight)
                        }
                        it("paginates") {
                            expect(sut.objectCount).toEventually(equal(200))
                        }
                    }
                }
            }
            fdescribe("products navigation") {
                describe("image pre-caching") {
                    context("initial movement") {
                        var products: [MockProduct]!
                        beforeEach {
                            products = MockProduct.makeMocks(count: 20)
                            for i in 0..<products.count {
                                var product = products[i]
                                product.images = [LGFile(id: nil, url: URL.makeRandom())]
                                products[i] = product
                            }
                            let productListModels = products.map { ProductCellModel.productCell(product: $0) }
                            buildSut(productListModels: productListModels, initialProduct: product)
                        }
                        it("requests images for items 0-3") {
                            let images = products.prefix(through: 3).flatMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                    }
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
