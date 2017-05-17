//
//  FilterProductListRequesterFactorySpec.swift
//  LetGo
//
//  Created by Dídac on 16/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class FilterProductListRequesterFactorySpec: QuickSpec {

    var finalMultiRequester: ProductListMultiRequester!

    override func spec() {

        describe ("multiple requesters generation") {
            context ("not car related") {
                beforeEach {
                    let filters = ProductFilters()
                    self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                }
                it ("multi requester has only 1 requester") {
                    expect(self.finalMultiRequester.numOfRequesters) == 1
                }
            }
            context ("car related") {
                context ("car details not specified") {
                    beforeEach {
                        var filters = ProductFilters()
                        filters.selectedCategories = [.cars]
                        self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                    }
                    it ("multi requester has only 1 requester") {
                        expect(self.finalMultiRequester.numOfRequesters) == 1
                    }
                }
                context ("car details specified") {
                    beforeEach {
                        var filters = ProductFilters()
                        filters.selectedCategories = [.cars]
                        filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                        filters.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: false)
                        filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)
                        self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                    }
                    it ("multi requester has 4 requesters") {
                        expect(self.finalMultiRequester.numOfRequesters) == 4
                    }
                }
            }
        }
    }
}
