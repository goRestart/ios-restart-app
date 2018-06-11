import LGCoreKit

extension Array where Element == ServiceSubtype {
    func makeCreationParams(imagesIds: [String],
                            location: LGLocationCoordinates2D,
                            postalAddress: PostalAddress, currency: Currency,
                            postListingState: PostListingState) -> [ListingCreationParams] {
        return self.enumerated().map { (index, subtype) in
            let serviceAttribute = ServiceAttributes(subtypeId: subtype.id)
            let imageFile = LGFile(id: imagesIds[safeAt: index], url: nil)
            return ListingCreationParams.make(title: subtype.name,
                                              description: "",
                                              currency: currency,
                                              location: location,
                                              postalAddress: postalAddress,
                                              postListingState: postListingState.updating(servicesInfo: serviceAttribute, uploadedImages: [imageFile]))
        }
    }
}
