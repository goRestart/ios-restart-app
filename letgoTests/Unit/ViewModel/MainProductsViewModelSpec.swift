//
//  MainProductsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble


class MainProductsViewModelSpec: QuickSpec {
    override func spec() {
       
        describe("MainProductsViewModelSpec") {
    
            var sut: MainProductsViewModel!
            var keyValueStorage: MockKeyValueStorage!
            var filters: ProductFilters!
            var mockFeatureFlags: MockFeatureFlags!
            
            beforeEach {
                keyValueStorage = MockKeyValueStorage()
                mockFeatureFlags = MockFeatureFlags()
                filters = ProductFilters()
            }
          
            context("Initialization") {
                    it("has firstDate nil (first time in Letgo)") {
                        keyValueStorage[.sessionNumber] = 1
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, trendingSearchesRepository: Core.trendingSearchesRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: TrackerProxy.sharedInstance, filters: filters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags)
                        expect(sut.currentActiveFilters?.selectedCategories) == []
                    }
                    it("has firstDate no nil (more than one time in Letgo)") {
                        keyValueStorage[.sessionNumber] =  2
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, trendingSearchesRepository: Core.trendingSearchesRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: TrackerProxy.sharedInstance, filters: filters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags)
                        expect(sut.currentActiveFilters?.selectedCategories) == []
                    }
            }
            
            context("Filter edition") {
                var userFilters: ProductFilters!
                var filtersViewModel: FiltersViewModel!
                
                beforeEach {
                    filtersViewModel = FiltersViewModel()
                    userFilters = ProductFilters()
                    userFilters.distanceRadius = 50
                    userFilters.selectedCategories = []
                }
                    beforeEach {
                        keyValueStorage[.sessionNumber] = 1
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, trendingSearchesRepository: Core.trendingSearchesRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: TrackerProxy.sharedInstance, filters: filters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags)
                    }
                    context("when user set some filters") {
                        
                        beforeEach {
                            sut.viewModelDidUpdateFilters(filtersViewModel, filters: userFilters)
                        }
                        it("has no filters with liquid categories") {
                            expect(sut.currentActiveFilters?.selectedCategories) == []
                        }
                        it("has filters set by user") {
                            expect(sut.currentActiveFilters?.distanceRadius) == 50
                        }
                        it("has no categories set by user ") {
                            expect(sut.userActiveFilters?.selectedCategories) == []
                        }
                    }
                    
                    context("when user set filters and remove them") {
                        beforeEach {
                            let userFiltersRemoved = ProductFilters()
                            sut.viewModelDidUpdateFilters(filtersViewModel, filters: userFiltersRemoved)
                        }
                        it("has not filters set by user") {
                            expect(sut.userActiveFilters?.selectedCategories) == []
                        }
                        it("has no liquid categories on requester") {
                            expect(sut.currentActiveFilters?.selectedCategories) == []
                        }
                    }
            }
        }
    }
}

