//
//  ListingRepositoryParams+MockFactory.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

class MockProductCreationParams: ProductCreationParams, MockFactory {
    required init() {
        super.init(name: String?.makeRandom(),
                   description: String?.makeRandom(),
                   price: ListingPrice.makeMock(),
                   category: ListingCategory.makeMock(),
                   currency: Currency.makeMock(),
                   location: LGLocationCoordinates2D.makeMock(),
                   postalAddress: PostalAddress.makeMock(),
                   languageCode: Locale.makeRandom().identifier,
                   images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 4)))
    }

    public static func makeMock() -> Self {
        return self.init()
    }
}

class MockProductEditionParams: ProductEditionParams, MockFactory {
    required init() {
        let product = MockProduct.makeMock()
        let productId = String.makeRandom()
        let userId = String.makeRandom()
        super.init(product: product, productId: productId, userId: userId)
    }

    init(productId: String, userId: String) {
        let product = MockProduct.makeMock()
        super.init(product: product, productId: productId, userId: userId)
    }

    public static func makeMock() -> Self {
        return self.init()
    }
}

class MockCarCreationParams: CarCreationParams, MockFactory {
    required init() {
        super.init(name: String?.makeRandom(),
                   description: String?.makeRandom(),
                   price: ListingPrice.makeMock(),
                   category: ListingCategory.makeMock(),
                   currency: Currency.makeMock(),
                   location: LGLocationCoordinates2D.makeMock(),
                   postalAddress: PostalAddress.makeMock(),
                   images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 4)),
                   carAttributes: CarAttributes.makeMock())
    }
    
    public static func makeMock() -> Self {
        return self.init()
    }
}

class MockCarEditionParams: CarEditionParams, MockFactory {
    required init() {
        let car = MockCar.makeMock()
        let carId = String.makeRandom()
        let userId = String.makeRandom()
        super.init(car: car, carId: carId, userId: userId)
    }
    
    init(carId: String, userId: String) {
        let car = MockCar.makeMock()
        super.init(car: car, carId: carId, userId: userId)
    }
    
    public static func makeMock() -> Self {
        return self.init()
    }
}
