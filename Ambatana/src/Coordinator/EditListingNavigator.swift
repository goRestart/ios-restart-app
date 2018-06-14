//
//  EditListingNavigator.swift
//  LetGo
//
//  Created by Facundo Menzella on 16/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol EditListingNavigator: class {
    func editingListingDidCancel()
    func editingListingDidFinish(_ editedListing: Listing,
                                 bumpUpProductData: BumpUpProductData?,
                                 timeSinceLastBump: TimeInterval?,
                                 maxCountdown: TimeInterval)
    func openListingAttributePicker(viewModel: ListingAttributeSingleSelectPickerViewModel)
}
