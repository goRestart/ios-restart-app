//
//  TaxonomiesMemoryDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 18/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo

class TaxonomiesMemoryDAO: TaxonomiesDAO {

    var taxonomies: [Taxonomy] = []

    func save(taxonomies: [Taxonomy]) {
        self.taxonomies = taxonomies
    }

    func clean() {
        taxonomies = []
    }

    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonTaxonomiesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let taxonomiesList = decoderArray(jsonTaxonomiesList) else { return }
            save(taxonomies: taxonomiesList)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create Taxonomies first run memory cache: \(error)")
        }
    }

    private func decoderArray(_ object: Any) -> [Taxonomy]? {
        guard let taxonomies = Array<LGTaxonomy>.filteredDecode(JSON(object)).value else { return nil }
        return taxonomies
    }
}
