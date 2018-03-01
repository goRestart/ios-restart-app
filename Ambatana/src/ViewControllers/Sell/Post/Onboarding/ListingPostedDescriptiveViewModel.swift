//
//  ListingPostedDescriptiveViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class ListingPostedDescriptiveViewModel: BaseViewModel {
    
    weak var navigator: PostingAdvancedCreateProductNavigator?
    
    private let tracker: Tracker
    
    
    // MARK: - Lifecycle
    
    override init() {
        self.tracker = TrackerProxy.sharedInstance
    }
    
    
    // MARK: - Navigation
    
    func closePosting() {
        navigator?.closePosting()
    }
}
