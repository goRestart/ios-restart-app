//
//  Listing+MockFactory.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

extension Listing: MockFactory {
    public static func makeMock() -> Listing {
        switch Int.makeRandom(min: 0, max: 1) {
        case 0:
            return .product(MockProduct.makeMock())
        case 1:
            return .car(MockCar.makeMock())
        default:
            return .car(MockCar.makeMock())
        }
    }
    
    public static func makeListing(price: ListingPrice) -> Listing {
        let listing = Listing.makeMock()
        switch listing {
        case .car(let car):
            var carMock = MockCar(car: car)
            carMock.price = price
            return Listing.car(carMock)
        case .realEstate(let realEstate):
            var realEstate = MockRealEstate(realEstate: realEstate)
            realEstate.price = price
            return Listing.realEstate(realEstate)
        case .product(let product):
            var productMock = MockProduct(product: product)
            productMock.price = price
            return Listing.product(productMock)
        case .service(let service):
            var serviceMock = MockService(service: service)
            serviceMock.price = price
            return Listing.service(service)
        }
    }
}
