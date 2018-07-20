//
//  FiltersNavigator.swift
//  LetGo
//
//  Created by Nestor on 30/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol FiltersNavigator: class {
    func openEditLocation(withViewModel viewModel: EditLocationViewModel)
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel)
    func openTaxonomyList(withViewModel viewModel: TaxonomiesViewModel)
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel)
    func openServicesDropdown(viewModel: DropdownViewModel)
    func closeFilters()
}
