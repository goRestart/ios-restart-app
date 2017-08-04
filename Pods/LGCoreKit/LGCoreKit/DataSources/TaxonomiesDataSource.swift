//
//  TaxonomiesDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias TaxonomiesDataSourceResult = Result<[Taxonomy], ApiError>
typealias TaxonomiesDataSourceCompletion = (TaxonomiesDataSourceResult) -> Void

protocol TaxonomiesDataSource {
    func index(countryCode: String, locale: Locale?, completion: TaxonomiesDataSourceCompletion?)
}
