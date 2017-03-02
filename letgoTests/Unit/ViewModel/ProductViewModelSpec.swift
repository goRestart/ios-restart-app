//
//  ProductViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ProductViewModelSpec: BaseViewModelSpec {

    var lastBuyersToRate: [UserProduct]?
    var buyerToRateResult: String?
    var shownAlertText: String?
    var shownFavoriteBubble: Bool?

    override func spec() {
        var sut: ProductViewModel!

        var sessionManager: MockSessionManager!
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
        var bottomButtonsObserver: TestableObserver<[UIAction]>!


        describe("ProductViewModelSpec") {

            func buildProductViewModel() {
                let socialSharer = SocialSharer()
                sut = ProductViewModel(product: product,
                                        myUserRepository: myUserRepository,
                                        productRepository: productRepository,
                                        commercializerRepository: commercializerRepository,
                                        chatWrapper: chatWrapper,
                                        chatViewMessageAdapter: ChatViewMessageAdapter(),
                                        locationManager: locationManager,
                                        countryHelper: countryHelper,
                                        socialSharer: socialSharer,
                                        featureFlags: featureFlags,
                                        purchasesShopper: purchasesShopper,
                                        notificationsManager: notificationsManager,
                                        monetizationRepository: monetizationRepository,
                                        tracker: tracker)
                sut.delegate = self
                sut.navigator = self

                disposeBag = DisposeBag()
                sut.actionButtons.asObservable().bindTo(bottomButtonsObserver).addDisposableTo(disposeBag)
            }

            beforeEach {
                sessionManager = MockSessionManager()
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

                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                bottomButtonsObserver = scheduler.createObserver(Array<UIAction>.self)

                self.resetViewModelSpec()
            }
            describe("mark as sold") {
                beforeEach {
                    sessionManager.loggedIn = true
                    let myUser = MockMyUser.makeMock()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct.makeMock()
                    var userProduct = MockUserProduct.makeMock()
                    userProduct.objectId = myUser.objectId
                    product.user = userProduct
                    product.status = .approved

                    productRepository.markAsSoldVoidResult = ProductVoidResult(Void())
                    var soldProduct = MockProduct(product: product)
                    soldProduct.status = .sold
                    productRepository.productResult = ProductResult(soldProduct)
                }
                context("buyer selection a/b enabled"){
                    beforeEach {
                        featureFlags.userRatingMarkAsSold = true
                    }
                    context("there are possible buyers") {
                        var possibleBuyers: [UserProduct]!
                        beforeEach {
                            possibleBuyers = [UserProduct]()
                            for _ in 0..<5 {
                                possibleBuyers.append(MockUserProduct.makeMock())
                            }
                            productRepository.productBuyersResult = ProductBuyersResult(possibleBuyers)
                        }
                        context("one is selected") {
                            beforeEach {
                                self.buyerToRateResult = possibleBuyers.last?.objectId

                                buildProductViewModel()
                                sut.active = true

                                // There should appear one button
                                expect(sut.actionButtons.value.count).toEventually(equal(1))
                                sut.actionButtons.value.first?.action()

                                expect(tracker.trackedEvents.count).toEventually(equal(1))
                            }
                            it("has mark as sold and then sell it again button") {
                                let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                                expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                            }
                            it("has requested buyer selection with buyers array") {
                                expect(self.lastBuyersToRate?.count) == possibleBuyers.count
                            }
                            it("has called to mark as sold with correct buyerId") {
                                expect(productRepository.markAsSoldBuyerId) == self.buyerToRateResult
                            }
                            it("has a mark as sold tracked event with correct user-sold-to") {
                                let event = tracker.trackedEvents.last
                                expect(event?.name.rawValue) == "product-detail-sold"
                                expect(event?.params?[.userSoldTo] as? String) == "true"
                            }
                        }
                        context("outside letgo is selected") {
                            beforeEach {
                                self.buyerToRateResult = nil

                                buildProductViewModel()
                                sut.active = true

                                // There should appear one button
                                expect(sut.actionButtons.value.count).toEventually(equal(1))
                                sut.actionButtons.value.first?.action()

                                expect(tracker.trackedEvents.count).toEventually(equal(1))
                            }
                            it("has mark as sold and then sell it again button") {
                                let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                                expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                            }
                            it("has requested buyer selection with buyers array") {
                                expect(self.lastBuyersToRate?.count) == possibleBuyers.count
                            }
                            it("has called to mark as sold with correct buyerId") {
                                expect(productRepository.markAsSoldBuyerId).to(beNil())
                            }
                            it("has a mark as sold tracked event with correct user-sold-to") {
                                let event = tracker.trackedEvents.last
                                expect(event?.name.rawValue) == "product-detail-sold"
                                expect(event?.params?[.userSoldTo] as? String) == "false"
                            }
                        }
                    }
                    context("there are no possible buyers") {
                        beforeEach {
                            productRepository.productBuyersResult = ProductBuyersResult([])

                            buildProductViewModel()
                            sut.active = true

                            // There should appear one button
                            expect(sut.actionButtons.value.count).toEventually(equal(1))
                            sut.actionButtons.value.first?.action()

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("has mark as sold and then sell it again button") {
                            let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                            expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                        }
                        it("hasn't requested buyer selection") {
                            expect(self.lastBuyersToRate).to(beNil())
                        }
                        it("has shown mark as sold alert") {
                            expect(self.shownAlertText!) == LGLocalizedString.productMarkAsSoldConfirmMessage
                        }
                        it("has called to mark as sold with correct buyerId") {
                            expect(productRepository.markAsSoldBuyerId).to(beNil())
                        }
                        it("has a mark as sold tracked event with correct user-sold-to") {
                            let event = tracker.trackedEvents.last!
                            expect(event.name.rawValue) == "product-detail-sold"
                            expect(event.params![.userSoldTo] as? String) == "no-conversations"
                        }
                    }
                }
                context("buyer selection a/b disabled"){
                    beforeEach {
                        featureFlags.userRatingMarkAsSold = false
                        var possibleBuyers = [UserProduct]()
                        for _ in 0..<5 {
                            possibleBuyers.append(MockUserProduct.makeMock())
                        }
                        productRepository.productBuyersResult = ProductBuyersResult(possibleBuyers)

                        buildProductViewModel()
                        sut.active = true

                        // There should appear one button
                        expect(sut.actionButtons.value.count).toEventually(equal(1))
                        sut.actionButtons.value.first?.action()

                        expect(tracker.trackedEvents.count).toEventually(equal(1))
                    }
                    it("has mark as sold and then sell it again button") {
                        let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                        expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                    }
                    it("hasn't requested buyer selection") {
                        expect(self.lastBuyersToRate).to(beNil())
                    }
                    it("has shown mark as sold alert") {
                        expect(self.shownAlertText!) == LGLocalizedString.productMarkAsSoldConfirmMessage
                    }
                    it("has called to mark as sold with correct buyerId") {
                        expect(productRepository.markAsSoldBuyerId).to(beNil())
                    }
                    it("has a mark as sold tracked event with no user-sold-to") {
                        let event = tracker.trackedEvents.last!
                        expect(event.name.rawValue) == "product-detail-sold"
                        expect(event.params![.userSoldTo]).to(beNil())
                    }
                }
            }

            describe("add to favorites") {
                beforeEach {
                    sessionManager.loggedIn = true
                    product = MockProduct.makeMock()
                    product.status = .approved
                    product.favorite = false
                    self.shownFavoriteBubble = false
                }
                context("Contact the seller AB test enabled"){
                    beforeEach {
                        featureFlags.shouldContactSellerOnFavorite = true
                        buildProductViewModel()
                        sut.switchFavorite()
                    }

                    it("shows bubble up") {
                        expect(self.shownFavoriteBubble).toEventually(equal(true))
                    }
                }
                context("Contact the seller AB test disabled"){
                    beforeEach {
                        featureFlags.shouldContactSellerOnFavorite = false
                        buildProductViewModel()
                        sut.switchFavorite()
                    }

                    it("does not show bubble up") {
                        expect(self.shownFavoriteBubble).toEventually(equal(false))
                    }
                }
            }

            describe("remove from favorites") {
                beforeEach {
                    sessionManager.loggedIn = true
                    product = MockProduct.makeMock()
                    product.status = .approved
                    product.favorite = true
                    self.shownFavoriteBubble = false
                }

                context("Contact the seller AB test enabled"){
                    beforeEach {
                        featureFlags.shouldContactSellerOnFavorite = true
                        buildProductViewModel()
                        sut.switchFavorite()
                    }
                    
                    it("does not show bubble up") {
                        expect(self.shownFavoriteBubble).toEventually(equal(false))
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
        
    }

    override func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        shownAlertText = message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            actions.last?.action()
        }
    }
}

extension ProductViewModelSpec: ProductViewModelDelegate {

    func vmOpenMainSignUp(_ signUpVM: SignUpViewModel, afterLoginAction: @escaping () -> ()) {}

    func vmOpenStickersSelector(_ stickers: [Sticker]) {}

    func vmOpenPromoteProduct(_ promoteVM: PromoteProductViewModel) {}
    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel) {}
    func vmAskForRating() {}
    func vmShowOnboarding() {}
    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction]) {}

    func vmShareDidFailedWith(_ error: String) {}
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (UIViewController(), nil)
    }

    // Bump Up
    func vmResetBumpUpBannerCountdown() {}
}

extension ProductViewModelSpec: ProductDetailNavigator {
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


