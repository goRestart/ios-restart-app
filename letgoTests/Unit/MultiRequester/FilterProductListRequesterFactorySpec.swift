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
                    context ("only make") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 2 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 2
                        }
                    }
                    context ("only make, custom") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "", isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 2 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 2
                        }
                    }
                    context ("make & model") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                            filters.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 3 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 3
                        }
                    }
                    context ("make & custom model") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                            filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 3 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 3
                        }
                    }
                    context ("custom make & custom model") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "", isNegated: false)
                            filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 3 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 3
                        }
                    }
                    context ("make, model & year") {
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
                    context ("make, custom model & year") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                            filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)
                            filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 4 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 4
                        }
                    }
                    context ("custom make, custom model & year") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "", isNegated: false)
                            filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)
                            filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 4 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 4
                        }
                    }
                    context ("make, model & year start & end") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                            filters.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: false)
                            filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)
                            filters.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 4 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 4
                        }
                    }
                    context ("only year end") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 2 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 2
                        }
                    }
                    context ("only year, but start and end") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)
                            filters.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: false)
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters, queryString: nil, itemsPerPage: 20)
                        }
                        it ("multi requester has 2 requesters") {
                            expect(self.finalMultiRequester.numOfRequesters) == 2
                        }
                    }
                }
            }
        }
    }
}
