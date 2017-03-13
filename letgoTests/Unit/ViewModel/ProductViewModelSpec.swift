//
//  ProductViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble

enum BumpUpStatus {
    case notAvailable
    case paymentFailed
    case bumpFailed
    case bumpSucceeded
}

class ProductViewModelSpec: BaseViewModelSpec {

    var lastBuyersToRate: [UserProduct]?
    var buyerToRateResult: String?
    var shownAlertText: String?
    var shownFavoriteBubble: Bool?
    var calledLogin: Bool?
    var bumpUpStatus: BumpUpStatus?

    override func spec() {
        var sut: ProductViewModel!

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
        var scheduler: TestScheduler!
        var bottomButtonsObserver: TestableObserver<[UIAction]>!
        var isFavoriteObserver: TestableObserver<Bool>!
        var directChatMessagesObserver: TestableObserver<[ChatViewMessage]>!


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
                sut.isFavorite.asObservable().bindTo(isFavoriteObserver).addDisposableTo(disposeBag)
                sut.directChatMessages.observable.bindTo(directChatMessagesObserver).addDisposableTo(disposeBag)
            }

            beforeEach {
                sut = nil
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

                purchasesShopper.delegate = self
                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                bottomButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                isFavoriteObserver = scheduler.createObserver(Bool.self)
                directChatMessagesObserver = scheduler.createObserver(Array<ChatViewMessage>.self)

                self.resetViewModelSpec()
            }
            afterEach {
                scheduler.stop()
                disposeBag = nil
            }
            describe("mark as sold") {
                beforeEach {
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
            describe("favorite") {
                var savedProduct: MockProduct!
                beforeEach {
                    let myUser = MockMyUser.makeMock()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct.makeMock()
                    product.status = .approved
                    savedProduct = MockProduct(product: product)
                    self.shownFavoriteBubble = false
                }
                describe("add to favorites") {
                    beforeEach {
                        product.favorite = false
                        savedProduct.favorite = true
                        productRepository.productResult = ProductResult(savedProduct)
                        buildProductViewModel()
                    }
                    context("Contact the seller AB test enabled"){
                        beforeEach {
                            featureFlags.shouldContactSellerOnFavorite = true
                            sut.switchFavorite()
                            expect(isFavoriteObserver.eventValues.count).toEventually(equal(2))
                        }
                        it("shows bubble up") {
                            expect(self.shownFavoriteBubble) == true
                        }
                        it("favorite value is true") {
                            expect(isFavoriteObserver.lastValue) == true
                        }
                    }
                    context("Contact the seller AB test disabled"){
                        beforeEach {
                            featureFlags.shouldContactSellerOnFavorite = false
                            sut.switchFavorite()
                            expect(isFavoriteObserver.eventValues.count).toEventually(equal(2))
                        }

                        it("does not show bubble up") {
                            expect(self.shownFavoriteBubble) == false
                        }
                        it("favorite value is true") {
                            expect(isFavoriteObserver.lastValue) == true
                        }
                    }
                }

                describe("remove from favorites") {
                    beforeEach {
                        product.favorite = true
                        savedProduct.favorite = false
                        productRepository.productResult = ProductResult(savedProduct)
                        buildProductViewModel()
                    }

                    context("Contact the seller AB test enabled"){
                        beforeEach {
                            featureFlags.shouldContactSellerOnFavorite = true
                            sut.switchFavorite()
                            expect(isFavoriteObserver.eventValues.count).toEventually(equal(2))
                        }
                        
                        it("does not show bubble up") {
                            expect(self.shownFavoriteBubble) == false
                        }
                        it("favorite value is true") {
                            expect(isFavoriteObserver.lastValue) == false
                        }
                    }

                    context("Contact the seller AB test disabled"){
                        beforeEach {
                            featureFlags.shouldContactSellerOnFavorite = false
                            sut.switchFavorite()
                            expect(isFavoriteObserver.eventValues.count).toEventually(equal(2))
                        }

                        it("does not show bubble up") {
                            expect(self.shownFavoriteBubble) == false
                        }
                        it("favorite value is true") {
                            expect(isFavoriteObserver.lastValue) == false
                        }
                    }
                }
            }
            describe("direct messages") {
                describe("quick answer") {
                    context("success first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildProductViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)

                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                    }
                    context("success non first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(false)]
                            buildProductViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message"]
                        }
                    }
                    context("failure") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(error: .notFound)]
                            buildProductViewModel()
                            sut.sendQuickAnswer(quickAnswer: .meetUp)
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == [QuickAnswer.meetUp.text]
                        }
                        describe("failure arrives") {
                            beforeEach {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(equal(true))
                            }
                            it("element is removed from directMessages") {
                                expect(directChatMessagesObserver.lastValue?.count) == 0
                            }
                            it("didn't track any message sent event") {
                                expect(tracker.trackedEvents.count) == 0
                            }
                        }
                    }
                }
                describe("text message") {
                    context("success first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(true)]
                            buildProductViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: false)

                            expect(tracker.trackedEvents.count).toEventually(equal(2))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-ask-question", "user-sent-message"]
                        }
                    }
                    context("success non first message") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(false)]
                            buildProductViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: true)

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        it("tracks sent first message + message sent") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["user-sent-message"]
                        }
                    }
                    context("failure") {
                        beforeEach {
                            chatWrapper.results = [ChatWrapperResult(error: .notFound)]
                            buildProductViewModel()
                            sut.sendDirectMessage("Hola que tal", isDefaultText: true)
                        }
                        it("requests logged in") {
                            expect(self.calledLogin) == true
                        }
                        it("adds one element on directMessages") {
                            expect(directChatMessagesObserver.lastValue?.map{ $0.value }) == ["Hola que tal"]
                        }
                        describe("failure arrives") {
                            beforeEach {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(equal(true))
                            }
                            it("element is removed from directMessages") {
                                expect(directChatMessagesObserver.lastValue?.count) == 0
                            }
                            it("didn't track any message sent event") {
                                expect(tracker.trackedEvents.count) == 0
                            }
                        }
                    }
                }
            }
            describe("priced bump up product") {
                describe ("ABTest enabled") {
                    context ("appstore payment fails") {
                        beforeEach {
                            self.bumpUpStatus = .notAvailable
                            purchasesShopper.paymentSucceeds = false
                            product = MockProduct.makeMock()
                            product.objectId = "product_id"
                            buildProductViewModel()
                            sut.bumpUpPurchaseableProduct = MockPurchaseableProduct.makeMock()
                            sut.paymentItemId = String.makeRandom()
                            sut.bumpUpProduct(productId: product.objectId!)
                        }
                        it ("bumpUpStatus is payment failed") {
                            expect(self.bumpUpStatus) == .paymentFailed
                        }
                    }
                    context ("appstore payment succeeds but bump fails") {
                        beforeEach {
                            self.bumpUpStatus = .notAvailable
                            purchasesShopper.paymentSucceeds = true
                            purchasesShopper.pricedBumpSucceeds = false
                            product = MockProduct.makeMock()
                            product.objectId = "product_id"
                            buildProductViewModel()
                            sut.bumpUpPurchaseableProduct = MockPurchaseableProduct.makeMock()
                            sut.paymentItemId = String.makeRandom()
                            sut.bumpUpProduct(productId: product.objectId!)
                        }
                        it ("bumpUpStatus is bump failed") {
                            expect(self.bumpUpStatus) == .bumpFailed
                        }
                    }
                    context ("appstore payment and bump succeed") {
                        beforeEach {
                            self.bumpUpStatus = .notAvailable
                            purchasesShopper.paymentSucceeds = true
                            purchasesShopper.pricedBumpSucceeds = true
                            product = MockProduct.makeMock()
                            product.objectId = "product_id"
                            buildProductViewModel()
                            sut.bumpUpPurchaseableProduct = MockPurchaseableProduct.makeMock()
                            sut.paymentItemId = String.makeRandom()
                            sut.bumpUpProduct(productId: product.objectId!)
                        }
                        it ("bumpUpStatus is bump suceeded") {
                            expect(self.bumpUpStatus) == .bumpSucceeded
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
        calledLogin = nil
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
    func openPayBumpUpForProduct(product: Product, purchaseableProduct: PurchaseableProduct, withPaymentItemId: String) {

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
        calledLogin = true
        loggedInAction()
    }
}


extension ProductViewModelSpec: PurchasesShopperDelegate {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct]) {
    }

    // Free Bump Up
    func freeBumpDidStart() {
    }

    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork) {
    }

    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork) {
    }

    // Priced Bump Up
    func pricedBumpDidStart() {

    }

    func pricedBumpDidSucceed() {
        bumpUpStatus = .bumpSucceeded
    }

    func pricedBumpDidFail() {
        bumpUpStatus = .bumpFailed
    }

    func pricedBumpPaymentDidFail() {
        bumpUpStatus = .paymentFailed
    }
}
