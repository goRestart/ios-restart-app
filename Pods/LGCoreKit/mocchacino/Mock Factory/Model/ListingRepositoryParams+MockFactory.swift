//
//  ListingRepositoryParams+MockFactory.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

extension ListingCreationParams: MockFactory {
    public static func makeMock() -> ListingCreationParams {
        switch Int.makeRandom(min: 0, max: 2) {
        case 0:
            return .product(MockProductCreationParams.makeMock())
        case 1:
            return .car(MockCarCreationParams.makeMock())
        case 2:
            return .realEstate(MockRealEstateCreationParams.makeMock())
        default:
            return .car(MockCarCreationParams.makeMock())
        }
    }
}

extension ListingEditionParams: MockFactory {
    public static func makeMock() -> ListingEditionParams {
        switch Int.makeRandom(min: 0, max: 2) {
        case 0:
            return .product(MockProductEditionParams.makeMock())
        case 1:
            return .car(MockCarEditionParams.makeMock())
        case 2:
            return .realEstate(MockRealEstateEditionParams.makeMock())
        default:
            return .car(MockCarEditionParams.makeMock())
        }
    }
}

class MockProductCreationParams: ProductCreationParams, MockFactory {
    required init() {
        super.init(name: String?.makeRandom(),
                   description: String?.makeRandom(),
                   price: ListingPrice.makeMock(),
                   category: ListingCategory.makeMock(),
                   currency: Currency.makeMock(),
                   location: LGLocationCoordinates2D.makeMock(),
                   postalAddress: PostalAddress.makeMock(),
                   images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 4)),
                   videos: MockVideo.makeMocks(count: Int.makeRandom(min: 0, max: 4)))
    }

    public static func makeMock() -> Self {
        return self.init()
    }
}

class MockProductEditionParams: ProductEditionParams, MockFactory {
    required init() {
        let product = MockProduct.makeMock()
        super.init(product: product)!
    }

    required init(mockedProduct: Product) {
        super.init(product: mockedProduct)!
    }
    
    public static func makeMock() -> Self {
        let product = MockProduct.makeMock()
        return self.init(mockedProduct: product)
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
                   videos: MockVideo.makeMocks(count: Int.makeRandom(min: 0, max: 4)),
                   carAttributes: CarAttributes.makeMock())
    }
    
    public static func makeMock() -> Self {
        return self.init()
    }
}

class MockCarEditionParams: CarEditionParams, MockFactory {
    required init(mockedCar: Car) {
        super.init(car: mockedCar)!
    }
    
    public static func makeMock() -> Self {
        let car = MockCar.makeMock()
        return self.init(mockedCar: car)
    }
}

class MockRealEstateCreationParams: RealEstateCreationParams, MockFactory {
    required init() {
        super.init(name: String?.makeRandom(),
                   description: String?.makeRandom(),
                   price: ListingPrice.makeMock(),
                   category: ListingCategory.makeMock(),
                   currency: Currency.makeMock(),
                   location: LGLocationCoordinates2D.makeMock(),
                   postalAddress: PostalAddress.makeMock(),
                   images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 4)),
                   videos: MockVideo.makeMocks(count: Int.makeRandom(min: 0, max: 4)),
                   realEstateAttributes: RealEstateAttributes.makeMock())
    }
    
    public static func makeMock() -> Self {
        return self.init()
    }
}

class MockRealEstateEditionParams: RealEstateEditionParams, MockFactory {
    
    required init(mockedRealEstate: RealEstate) {
        super.init(realEstate: mockedRealEstate)!
    }
    
    public static func makeMock() -> Self {
        let realEstate = MockRealEstate.makeMock()
        return self.init(mockedRealEstate: realEstate)
    }
}

