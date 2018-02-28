//
//  TaxonomiesApiDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 17/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

final class TaxonomiesApiDataSource: TaxonomiesDataSource {

    let apiClient: ApiClient

    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    // MARK: - Actions

    func index(countryCode: String, locale: Locale?, completion: TaxonomiesDataSourceCompletion?) {
        var params: [String: Any] = ["country_code" : countryCode]
        if let localeId = locale?.identifier {
            params["locale"] = localeId
        }
        let request = TaxonomiesRouter.index(params: params)
        apiClient.request(request, decoder: TaxonomiesApiDataSource.decoderArray, completion: completion)
    }


    // MARK: - Decoders

    private static func decoderArray(_ object: Any) -> [Taxonomy]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        // Ignore suggestive searches that can't be decoded
        do {
            let taxonomies = try JSONDecoder().decode(FailableDecodableArray<LGTaxonomy>.self, from: data)
            return taxonomies.validElements
        } catch {
            logAndReportParseError(object: object, entity: .taxonomies,
                                   comment: "could not parse [LGTaxonomy]")
        }
        return nil
    }
}
