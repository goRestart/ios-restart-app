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
    var expectedRequestersArray: [ProductListRequester]!

    override func spec() {

        describe ("multiple requesters generation") {
            context ("not car related") {
                beforeEach {
                    let filters = ProductFilters()
                    self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                   queryString: nil,
                                                                                                   itemsPerPage: 20,
                                                                                                   multiRequesterEnabled: true)
                }
                it ("multi requester has only 1 requester") {
                    expect(self.finalMultiRequester.numOfRequesters) == 1
                }
            }
            context ("car related") {
                beforeEach {
                    self.expectedRequestersArray = []
                }
                context ("car details not specified") {
                    context ("multi requester feature disabled") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]
                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           multiRequesterEnabled: false)
                        }
                        it ("multi requester has only 1 requester") {
                            expect(self.finalMultiRequester.numOfRequesters) == 1
                        }
                    }
                    context ("multi requester feature enabled") {
                        beforeEach {
                            var filters = ProductFilters()
                            filters.selectedCategories = [.cars]

                            let expectedRequester = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester.filters = filters
                            self.expectedRequestersArray = [expectedRequester]

                            self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           multiRequesterEnabled: true)
                        }
                        it ("multi requester has only 1 requester") {
                            expect(self.finalMultiRequester.numOfRequesters) == 1
                        }
                        it ("the requesters are the right ones") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                }
                context ("car details specified") {
                    context ("multi requester feature disabled") {
                        context ("make & model") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: false)
                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: false)
                            }
                            it ("multi requester has 1 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 1
                            }
                        }
                    }
                    context ("multi requester feature enabled") {
                        context ("only make") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters
                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: true)
                                expectedRequester2.filters = filters2
                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 2 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 2
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("only make, custom") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "", isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters
                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carMakeId = RetrieveListingParam<String>(value: "", isNegated: true)
                                expectedRequester2.filters = filters2
                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 2 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 2
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("make & model") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: true)
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: true)
                                filters4.carModelId = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester3, expectedRequester4]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 3 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 3
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("make & custom model") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "", isNegated: true)
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: true)
                                filters4.carModelId = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester3, expectedRequester4]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 3 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 3
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("custom make & custom model") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "", isNegated: true)
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "", isNegated: true)
                                filters4.carModelId = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester3, expectedRequester4]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 3 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 3
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("make, model & year") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: false)
                                filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: true)
                                expectedRequester2.filters = filters2

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: true)
                                filters3.carYearStart = nil
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: true)
                                filters4.carModelId = nil
                                filters4.carYearStart = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2, expectedRequester3, expectedRequester4]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 4 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 4
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("make, custom model & year") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)
                                filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: true)
                                expectedRequester2.filters = filters2

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "", isNegated: true)
                                filters3.carYearStart = nil
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: true)
                                filters4.carModelId = nil
                                filters4.carYearStart = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2, expectedRequester3, expectedRequester4]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 4 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 4
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("custom make, custom model & year") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carMakeId = RetrieveListingParam<String>(value: "", isNegated: false)
                                filters.carModelId = RetrieveListingParam<String>(value: "", isNegated: false)
                                filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: true)
                                expectedRequester2.filters = filters2

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "", isNegated: true)
                                filters3.carYearStart = nil
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "", isNegated: true)
                                filters4.carModelId = nil
                                filters4.carYearStart = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2, expectedRequester3, expectedRequester4]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 4 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 4
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
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

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: true)
                                filters2.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: true)
                                expectedRequester2.filters = filters2

                                let expectedRequester3 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters3 = filters
                                filters3.carModelId = RetrieveListingParam<String>(value: "modelId", isNegated: true)
                                filters3.carYearStart = nil
                                filters3.carYearEnd = nil
                                expectedRequester3.filters = filters3

                                let expectedRequester4 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters4 = filters
                                filters4.carMakeId = RetrieveListingParam<String>(value: "makeId", isNegated: true)
                                filters4.carModelId = nil
                                filters4.carYearStart = nil
                                filters4.carYearEnd = nil
                                expectedRequester4.filters = filters4

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2, expectedRequester3, expectedRequester4]


                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 4 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 4
                            }

                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("only year end") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: true)
                                expectedRequester2.filters = filters2

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 2 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 2
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                        context ("only year, but start and end") {
                            beforeEach {
                                var filters = ProductFilters()
                                filters.selectedCategories = [.cars]
                                filters.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: false)
                                filters.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: false)

                                let expectedRequester1 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                expectedRequester1.filters = filters

                                let expectedRequester2 = FilteredProductListRequester(itemsPerPage: 20, offset: 0)
                                var filters2 = filters
                                filters2.carYearStart = RetrieveListingParam<Int>(value: 2000, isNegated: true)
                                filters2.carYearEnd = RetrieveListingParam<Int>(value: 2015, isNegated: true)
                                expectedRequester2.filters = filters2

                                self.expectedRequestersArray = [expectedRequester1, expectedRequester2]

                                self.finalMultiRequester = FilterProductListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                               queryString: nil,
                                                                                                               itemsPerPage: 20,
                                                                                                               multiRequesterEnabled: true)
                            }
                            it ("multi requester has 2 requesters") {
                                expect(self.finalMultiRequester.numOfRequesters) == 2
                            }
                            it ("the requesters are the right ones") {
                                expect(self.finalMultiRequester.isEqual(toRequester: ProductListMultiRequester(requesters: self.expectedRequestersArray))) == true
                            }
                        }
                    }
                }
            }
        }
    }
}
