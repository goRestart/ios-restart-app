//
//  FilterListingListRequesterFactorySpec.swift
//  LetGo
//
//  Created by Dídac on 16/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class FilterListingListRequesterFactorySpec: QuickSpec {

    var finalMultiRequester: ListingListMultiRequester!
    var expectedRequestersArray: [ListingListRequester]!

    override func spec() {

        describe ("multiple requesters generation") {
            beforeEach {
                self.expectedRequestersArray = []
            }
            context ("not car related") {
                beforeEach {
                    let filters = ListingFilters()

                    let expectedRequester = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                    expectedRequester.filters = filters
                    self.expectedRequestersArray = [expectedRequester]

                    self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                   queryString: nil,
                                                                                                   itemsPerPage: 20,
                                                                                                   carSearchActive: false)
                }
                it ("only one requester, and is the same") {
                    expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                }
            }
            context ("car related") {
                context ("car details not specified") {
                    beforeEach {
                        var filters = ListingFilters()
                        filters.selectedCategories = [.cars]
                        
                        let expectedRequester = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                        expectedRequester.filters = filters
                        self.expectedRequestersArray = [expectedRequester]
                        
                        self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                       queryString: nil,
                                                                                                       itemsPerPage: 20,
                                                                                                       carSearchActive: false)
                    }
                    it ("only one requester, and is the same, only cars category") {
                        expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                    }
                }
                context ("car details specified") {
                    context ("only make") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = "makeId"
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters

                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("only make, custom") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = ""
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make 'others'") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("make & model") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = "makeId"
                            filters.carModelId = "modelId"
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make and model") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("make & custom model") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = "makeId"
                            filters.carModelId = ""
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make and model 'other'") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("custom make & custom model") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = ""
                            filters.carModelId = ""
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make 'others' and model 'other'") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("make, model & year") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = "makeId"
                            filters.carModelId = "modelId"
                            filters.carYearStart = 2000
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make and model and year") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("make, custom model & year") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = "makeId"
                            filters.carModelId = ""
                            filters.carYearStart = 2000
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make and model 'other' and year") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("custom make, custom model & year") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = ""
                            filters.carModelId = ""
                            filters.carYearStart = 2000
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make 'other', model 'other' and year") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("make, model & year start & end") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carMakeId = "makeId"
                            filters.carModelId = "modelId"
                            filters.carYearStart = 2000
                            filters.carYearEnd = 2015
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with make and model and year") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("only year end") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carYearEnd = 2015
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with year") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                    context ("only year, but start and end") {
                        beforeEach {
                            var filters = ListingFilters()
                            filters.selectedCategories = [.cars]
                            filters.carYearStart = 2000
                            filters.carYearEnd = 2015
                            
                            let expectedRequester1 = FilteredListingListRequester(itemsPerPage: 20, offset: 0)
                            expectedRequester1.filters = filters
                            
                            self.expectedRequestersArray = [expectedRequester1]
                            
                            self.finalMultiRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                                           queryString: nil,
                                                                                                           itemsPerPage: 20,
                                                                                                           carSearchActive: false)
                        }
                        it ("requesters with year") {
                            expect(self.finalMultiRequester.isEqual(toRequester: ListingListMultiRequester(requesters: self.expectedRequestersArray))) == true
                        }
                    }
                }
            }
        }
    }
}
