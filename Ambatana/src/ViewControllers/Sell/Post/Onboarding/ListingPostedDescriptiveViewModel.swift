//
//  ListingPostedDescriptiveViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingPostedDescriptiveViewModel: BaseViewModel {
    
    weak var navigator: BlockingPostingNavigator?
    
    private let tracker: Tracker
    private let listing: Listing
    private let images: [UIImage]

    
    // MARK: - Lifecycle
    
    init(listing: Listing, images: [UIImage]) {
        self.tracker = TrackerProxy.sharedInstance
        self.listing = listing
        self.images = images
        super.init()
    }
    
    
    // MARK: - Navigation
    
    func closePosting() {
        navigator?.closePosting()
    }
}
