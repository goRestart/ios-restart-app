extension Listing {
  private static let fakeListingId = "00000000-0000-0000-0000-000000000000"
  
  public static func makeFakeListing(with user: User) -> Listing {
    let userListing = MockUserListing(objectId: user.objectId,
                                      name: nil,
                                      avatar: nil,
                                      postalAddress: PostalAddress.makeMock(),
                                      status: UserStatus.makeMock(),
                                      banned: false,
                                      isDummy: false,
                                      type: .user)
    
    let product = LGProduct(objectId: fakeListingId,
                            updatedAt: Date(), createdAt: Date(),
                            name: nil,
                            nameAuto: nil,
                            descr: nil,
                            price: ListingPrice.makeMock(),
                            currency: Currency.makeMock(),
                            location: LGLocationCoordinates2D.makeMock(),
                            postalAddress: PostalAddress.makeMock(),
                            languageCode: nil,
                            category: ListingCategory.makeMock(),
                            status: ListingStatus.makeMock(),
                            thumbnail: nil,
                            thumbnailSize: nil,
                            images: [],
                            media: [],
                            mediaThumbnail: nil,
                            user: userListing,
                            featured: false)
    
    return Listing.product(product)
  }
}
