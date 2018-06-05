//  Copyright © 2018 Ambatana Inc. All rights reserved.

public class ServicesEditionParams: ServicesCreationParams {
    let serviceId: String
    let userId: String

    public convenience init?(listing: Listing) {
        let editedService = ServicesEditionParams.createServicesParams(withListing: listing)
        self.init(service: editedService)
    }

    public init?(service: Service) {
        guard let serviceId = service.objectId, let userId = service.user.objectId else { return nil }
        self.serviceId = serviceId
        self.userId = userId
        let videos: [Video] = service.media.flatMap(LGVideo.init)
        super.init(name: service.name,
                   description: service.descr,
                   price: service.price,
                   category: service.category,
                   currency: service.currency,
                   location: service.location,
                   postalAddress: service.postalAddress,
                   images: service.images,
                   videos: videos,
                   serviceAttributes: service.servicesAttributes)
        if let languageCode = service.languageCode {
            self.languageCode = languageCode
        }
    }

    func apiEditionEncode() -> [String: Any] {
        return super.apiServiceCreationEncode(userId: userId)
    }

    static private func createServicesParams(withListing listing: Listing) -> Service {
        return LGService(objectId: listing.objectId,
                         updatedAt: listing.updatedAt,
                         createdAt: listing.createdAt,
                         name: listing.name,
                         nameAuto: listing.nameAuto,
                         descr: listing.descr,
                         price: listing.price,
                         currency: listing.currency,
                         location: listing.location,
                         postalAddress: listing.postalAddress,
                         languageCode: listing.languageCode,
                         category: .cars,
                         status: listing.status,
                         thumbnail: listing.thumbnail,
                         thumbnailSize: listing.thumbnailSize,
                         images: listing.images,
                         media: listing.media,
                         mediaThumbnail: listing.mediaThumbnail,
                         user: listing.user,
                         featured: listing.featured,
                         servicesAttributes: listing.service?.servicesAttributes)
    }
}
