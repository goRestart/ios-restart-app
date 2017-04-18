extension MockCar: MockFactory {
    public static func makeMock() -> MockCar {
        return MockCar(objectId: String.makeRandom(),
                           name: String?.makeRandom(),
                           nameAuto: String?.makeRandom(),
                           descr: String?.makeRandom(),
                           price: ListingPrice.makeMock(),
                           currency: Currency.makeMock(),
                           location: LGLocationCoordinates2D.makeMock(),
                           postalAddress: PostalAddress.makeMock(),
                           languageCode: String?.makeRandom(),
                           category: .cars,
                           status: ListingStatus.makeMock(),
                           thumbnail: MockFile?.makeMock(),
                           thumbnailSize: LGSize?.makeMock(),
                           images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                           user: MockUserListing.makeMock(),
                           updatedAt: Date?.makeRandom(),
                           createdAt: Date?.makeRandom(),
                           featured: Bool?.makeRandom(),
                           favorite: Bool.makeRandom(),
                           carAttributes: CarAttributes.emptyCarAttributes()) //TODO: 🚔 need to create a makeRandom carAttributes!
    }
}
