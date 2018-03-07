//
//  ListingPostedDescriptiveViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum PostingDescriptionType {
    case withTitle
    case noTitle
}

class ListingPostedDescriptiveViewModel: BaseViewModel {

    var descriptionType: PostingDescriptionType

    var listingImageURL: URL? {
        return listing.images.first?.fileURL
    }

    var doneText: String {
        return "_Done! That was easy, right?"
    }

    var saveButtonText: String {
        return "_ Save this listing!"
    }

    var discardButtonText: String {
        return "_ Discard"
    }

    let listingImage = Variable<UIImage?>(nil)

    weak var navigator: PostingHastenedCreateProductNavigator?

    private let tracker: Tracker
    private let listing: Listing
    
    // MARK: - Lifecycle
    
    override convenience init() {
        var product = MockProduct.makeMock()
        product.name = Int.makeRandom(min: 0, max: 1) < 1 ? "Supa cool zing" : nil
        product.price = ListingPrice.normal(23.0)
        product.category = .electronics
        let listing: Listing = Listing.product(product)
        self.init(listing: listing, tracker: TrackerProxy.sharedInstance)
    }

    init(listing: Listing, tracker: Tracker) {
        self.tracker = tracker
        self.listing = listing

        self.descriptionType = listing.name != nil ? .withTitle : .noTitle
    }


    // MARK: - Private Methods

    func retrieveImageForAvatar() {

        guard let imageUrl = listingImageURL else { return }
        ImageDownloader.sharedInstance.downloadImageWithURL(imageUrl) { [weak self] result, url in
            guard let imageWithSource = result.value, url == self?.listingImageURL else { return }
            self?.listingImage.value = imageWithSource.image
        }
    }


    // MARK: - Navigation
    
    func closePosting() {
        navigator?.closePosting()
    }
}
