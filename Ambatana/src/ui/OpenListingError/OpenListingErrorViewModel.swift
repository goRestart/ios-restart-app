//
//  OpenListingErrorViewModel.swift
//  LetGo
//
//  Created by Dídac on 17/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol OpenListingErrorViewModelDelegate: BaseViewModelDelegate {}


class OpenListingErrorViewModel : BaseViewModel {

    private let listingId: String
    private let listingRepository: ListingRepository
    private let source: EventParameterProductVisitSource
    private let actionOnFirstAppear: ProductCarouselActionOnFirstAppear

    weak var navigator: ListingUnavailableNavigator?
    weak var delegate: OpenListingErrorViewModelDelegate?


    // MARK: Lifecycle

    convenience init(listingId: String, source: EventParameterProductVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        self.init(listingId: listingId,
                  source: source,
                  actionOnFirstAppear: actionOnFirstAppear,
                  listingRepository: Core.listingRepository)
    }

    init(listingId: String,
         source: EventParameterProductVisitSource,
         actionOnFirstAppear: ProductCarouselActionOnFirstAppear,
         listingRepository: ListingRepository) {
        self.listingId = listingId
        self.source = source
        self.actionOnFirstAppear = actionOnFirstAppear
        self.listingRepository = listingRepository

        super.init()
    }


    // MARK: - Public Methods

    func retryButtonPressed() {
        delegate?.vmShowLoading(nil)
        listingRepository.retrieve(listingId) { [weak self] result in
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
            if let value = result.value {
                self?.retrySucceeded(withListing: value)
            }
        }
    }

    func close(completion: (() -> Void)?) {
        delegate?.vmDismiss(completion)
    }

    func retrySucceeded(withListing listing: Listing) {
        close { [weak self] in
            guard let strongSelf = self else { return }
            self?.navigator?.retrySucceeded(withListing: listing,
                                            source: strongSelf.source,
                                            actionOnFirstAppear: strongSelf.actionOnFirstAppear)
        }
    }
}
