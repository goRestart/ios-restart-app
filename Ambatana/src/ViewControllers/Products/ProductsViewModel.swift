//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

protocol ProductsViewModelDelegate: class {
}

class ProductsViewModel: BaseViewModel {
    
    // MARK: - iVars
    // > Delegate
    weak var delegate: ProductsViewModelDelegate?
}
