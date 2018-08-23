//  Copyright © 2018 Ambatana Inc. All rights reserved.

extension ServiceAttributes: MockFactory {
    public static func makeMock() -> ServiceAttributes {
        return ServiceAttributes(typeId: String.makeRandom(),
                                 subtypeId: String.makeRandom(),
                                 listingType: ServiceListingType.job,
                                 paymentFrequency: PaymentFrequency.oneOff)
    }
}

