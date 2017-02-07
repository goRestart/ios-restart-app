//
//  ProductViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble


class ProductViewModelSpec: BaseViewModelSpec {

    var lastBuyersToRate: [UserProduct]?
    var buyerToRateResult: String?

    override func spec() {
        var sut: ProductViewModel!

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

        describe("ProductViewModelSpec") {

            func buildProductViewModel() {
                let socialSharer = SocialSharer()
                sut = ProductViewModel(myUserRepository: myUserRepository, productRepository: productRepository,
                                       commercializerRepository: commercializerRepository, chatWrapper: chatWrapper,
                                       stickersRepository: stickersRepository, locationManager: locationManager, countryHelper: countryHelper,
                                       product: product, thumbnailImage: nil, socialSharer: socialSharer, navigator: self,
                                       bubbleManager: bubbleNotificationManager, featureFlags: featureFlags, purchasesShopper: purchasesShopper,
                                       notificationsManager: notificationsManager, monetizationRepository: monetizationRepository)
            }

            beforeEach {
                myUserRepository = MockMyUserRepository()
                productRepository = MockProductRepository()
                commercializerRepository = MockCommercializerRepository()
                stickersRepository = MockStickersRepository()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct()
                bubbleNotificationManager = MockBubbleNotificationManager()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository()

                self.resetViewModelSpec()
            }
            fdescribe("mark as sold") {
                beforeEach {
                    let myUser = MockMyUser()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct()
                    product.user = MockUserProduct(myUser: myUser)
                    product.status = .approved
                    buildProductViewModel()
                    sut.active = true
                }
                it("has mark as sold button") {
                    expect(sut.actionButtons.value.first?.text).toEventually(equal(LGLocalizedString.productMarkAsSoldButton))
                }
            }
        }
    }

    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        lastBuyersToRate = nil
        buyerToRateResult = nil
    }
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
    func selectBuyerToRate(buyers: [UserProduct], completion: @escaping (String?) -> Void) {
        lastBuyersToRate = buyers
        let result = self.buyerToRateResult
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion(result)
        }
    }
}
