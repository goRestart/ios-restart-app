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

class ListingPostedDescriptiveViewModel: BaseViewModel, PostingCategoriesPickDelegate {

    var descriptionType: PostingDescriptionType

    var doneText: String {
        return LGLocalizedString.postDescriptionDoneText
    }

    var saveButtonText: String {
        return LGLocalizedString.postDescriptionSaveButtonText
    }

    var discardButtonText: String {
        return LGLocalizedString.postDescriptionDiscardButtonText
    }

    var listingInfoTitleText: String {
        return LGLocalizedString.postDescriptionInfoTitle.uppercased()
    }

    var namePlaceholder: String {
        return LGLocalizedString.postDescriptionNamePlaceholder
    }
    var categoryButtonPlaceholder: String {
        return LGLocalizedString.postDescriptionCategoryTitle
    }
    var descriptionPlaceholder: String {
        return LGLocalizedString.postDescriptionDescriptionPlaceholder
    }
    var categoryButtonImage: UIImage? {
        return #imageLiteral(resourceName: "ic_arrow_right_white").withRenderingMode(.alwaysTemplate)
    }

    private var nameChanged: Bool {
        return listingName.value != originalName.value
    }

    private var categoryChanged: Bool {
        return listingCategory.value != originalCategory
    }

    private var descriptionChanged: Bool {
        return listingDescription.value != originalDescription && listingDescription.value != ""
    }

    let listingImage: UIImage?
    let listingName = Variable<String>("")
    let listingCategory = Variable<ListingCategory?>(nil)
    let listingDescription = Variable<String?>(nil)

    let originalName = Variable<String>("")
    var originalCategory: ListingCategory?
    var originalDescription: String?

    weak var navigator: BlockingPostingNavigator?

    private let tracker: Tracker
    private var listing: Listing
    private let listingRepository: ListingRepository


    // MARK: - Lifecycle
    
    convenience init(listing: Listing, listingImages: [UIImage]) {
        self.init(listing: listing,
                  listingImages: listingImages,
                  tracker: TrackerProxy.sharedInstance,
                  listingRepository: Core.listingRepository)
    }

    init(listing: Listing, listingImages: [UIImage], tracker: Tracker,listingRepository: ListingRepository) {
        self.listing = listing
        self.listingImage = listingImages.first
        self.tracker = tracker
        self.listingRepository = listingRepository

        self.descriptionType = listing.nameAuto != nil ? .withTitle : .noTitle
        self.listingName.value = listing.nameAuto ?? ""
        self.originalName.value = listing.nameAuto ?? ""
        self.listingCategory.value = listing.category
        self.originalCategory = listing.category
        super.init()
        self.originalDescription = self.descriptionPlaceholder
    }


    // MARK: Public methods

    func updateListingNameWith(text: String?) {
        guard let name = text else { return }
        listingName.value = name
    }

    func updateListingDescriptionWith(text: String?) {
        listingDescription.value = text ?? descriptionPlaceholder
    }

    // MARK: - Private Methods

    private func infoHasChanged() -> Bool {
        return nameChanged || categoryChanged || descriptionChanged
    }


    // MARK: - Navigation

    func openCategoriesPicker() {
        navigator?.openCategoriesPickerWith(selectedCategory: listingCategory.value, delegate: self)
    }

    func closePosting(discardingListing: Bool) {
        defer {
            navigator?.closePosting()
        }
        if discardingListing {
            guard let listingId = listing.objectId else { return }
            listingRepository.delete(listingId: listingId, completion: nil)
        } else if infoHasChanged() {
            let updatedParams: ListingEditionParams
            if let category = listingCategory.value, category.isCar {
                guard let carParams = CarEditionParams(listing: listing) else { return }
                carParams.name = listingName.value
                carParams.category = .cars
                carParams.descr = descriptionChanged ? listingDescription.value : nil
                updatedParams = .car(carParams)
            } else {
                guard let productParams = ProductEditionParams(listing: listing) else { return }
                productParams.name = listingName.value
                productParams.category = listingCategory.value ?? .other
                productParams.descr = descriptionChanged ? listingDescription.value : nil
                updatedParams = .product(productParams)
            }
            listingRepository.update(listingParams: updatedParams, completion: nil)
        }
    }


    // MARK: PostingCategoriesPickDelegate

    func didSelectCategory(category: ListingCategory) {
        listingCategory.value = category
    }
}
