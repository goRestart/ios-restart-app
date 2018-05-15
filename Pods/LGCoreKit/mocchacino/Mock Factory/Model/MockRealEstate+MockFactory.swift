extension MockRealEstate: MockFactory {
    public static func makeMock() -> MockRealEstate {
        return MockRealEstate(objectId: String.makeRandom(),
                       name: String.makeRandom(),
                       nameAuto: String.makeRandom(),
                       descr: String.makeRandom(),
                       price: ListingPrice.makeMock(),
                       currency: Currency.makeMock(),
                       location: LGLocationCoordinates2D.makeMock(),
                       postalAddress: PostalAddress.makeMock(),
                       languageCode: String.makeRandom(),
                       category: .realEstate,
                       status: ListingStatus.makeMock(),
                       thumbnail: MockFile.makeMock(),
                       thumbnailSize: LGSize?.makeMock(),
                       images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                       media: MockMedia.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                       mediaThumbnail: MockMediaThumbnail.makeMock(),
                       user: MockUserListing.makeMock(),
                       updatedAt: Date.makeRandom(),
                       createdAt: Date.makeRandom(),
                       featured: Bool.makeRandom(),
                       realEstateAttributes: RealEstateAttributes.makeMock())
    }
}
