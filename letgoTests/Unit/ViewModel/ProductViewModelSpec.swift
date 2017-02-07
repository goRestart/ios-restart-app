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
    override func spec() {
        var sut: ProductViewModel!

        describe("ProductViewModelSpec") {
            beforeEach {
                let myUserRepository = MockMyUserRepository()
                let productRepository = MockProductRepository()
                let commercializerRepository = MockCommercializerRepository()
                let stickersRepository = MockStickersRepository()
                let chatWrapper = MockChatWrapper()
                let locationManager = MockLocationManager()
                let countryHelper = CountryHelper.mock()
                let product = MockProduct()
                let socialSharer = SocialSharer()
                let bubbleNotificationManager = MockBubbleNotificationManager()
                let featureFlags = MockFeatureFlags()
                let purchasesShopper = MockPurchasesShopper()
                let notificationsManager = MockNotificationsManager()
                let monetizationRepository = MockMonetizationRepository()
                sut = ProductViewModel(myUserRepository: myUserRepository, productRepository: productRepository,
                     commercializerRepository: commercializerRepository, chatWrapper: chatWrapper,
                     stickersRepository: stickersRepository, locationManager: locationManager, countryHelper: countryHelper,
                     product: product, thumbnailImage: nil, socialSharer: socialSharer, navigator: self,
                     bubbleManager: bubbleNotificationManager, featureFlags: featureFlags, purchasesShopper: purchasesShopper,
                     notificationsManager: notificationsManager, monetizationRepository: monetizationRepository)
            }
            describe("mark as sold") {
                
            }
        }
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

    }
}
