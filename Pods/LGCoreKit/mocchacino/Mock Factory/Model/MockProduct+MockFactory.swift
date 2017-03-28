extension MockProduct: MockFactory {
    public static func makeMock() -> MockProduct {
        return MockProduct(objectId: String.makeRandom(),
                           name: String?.makeRandom(),
                           nameAuto: String?.makeRandom(),
                           descr: String?.makeRandom(),
                           price: ListingPrice.makeMock(),
                           currency: Currency.makeMock(),
                           location: LGLocationCoordinates2D.makeMock(),
                           postalAddress: PostalAddress.makeMock(),
                           languageCode: String?.makeRandom(),
                           category: ListingCategory.makeMock(),
                           status: ListingStatus.makeMock(),
                           thumbnail: MockFile?.makeMock(),
                           thumbnailSize: LGSize?.makeMock(),
                           images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                           user: MockUserListing.makeMock(),
                           updatedAt: Date?.makeRandom(),
                           createdAt: Date?.makeRandom(),
                           featured: Bool?.makeRandom(),
                           favorite: Bool.makeRandom())
    }
}
