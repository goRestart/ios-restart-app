extension MockProduct: MockFactory {
    public static func makeMock() -> MockProduct {
        return MockProduct(objectId: String.makeRandom(),
                           name: String?.makeRandom(),
                           nameAuto: String?.makeRandom(),
                           descr: String?.makeRandom(),
                           price: ProductPrice.makeMock(),
                           currency: Currency.makeMock(),
                           location: LGLocationCoordinates2D.makeMock(),
                           postalAddress: PostalAddress.makeMock(),
                           languageCode: String?.makeRandom(),
                           category: ProductCategory.makeMock(),
                           status: ProductStatus.makeMock(),
                           thumbnail: MockFile?.makeMock(),
                           thumbnailSize: LGSize?.makeMock(),
                           images: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                           user: MockUserProduct.makeMock(),
                           updatedAt: Date?.makeRandom(),
                           createdAt: Date?.makeRandom(),
                           featured: Bool?.makeRandom(),
                           favorite: Bool.makeRandom())
    }
}
