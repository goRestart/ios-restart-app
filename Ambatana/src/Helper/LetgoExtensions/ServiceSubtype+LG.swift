
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
    
    var trackingValue: String? {
        guard !isEmpty else { return nil }
        return compactMap { $0.id }.joined(separator: ",")
    }
    
}

//  MARK: - ServiceSubtype+DropdownCellViewModel

extension Collection where Element == ServiceSubtype {
    
    var cellRepresentables: [DropdownCellRepresentable] {
        return self.map {
            let cellContent = DropdownCellContent(type: .item(featured: $0.isHighlighted), title: $0.name, id: $0.id)
            return DropdownCellViewModel(withContent: cellContent, state: .deselected)
        }
    }
}
