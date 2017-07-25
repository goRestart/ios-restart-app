//
//  TaxonomiesDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 18/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

protocol TaxonomiesDAO {
    var taxonomies: [Taxonomy] { get }
    func save(taxonomies: [Taxonomy])
    func clean()
    func loadFirstRunCacheIfNeeded(jsonURL: URL)
}
