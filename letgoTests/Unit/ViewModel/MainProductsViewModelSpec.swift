//
//  MainProductsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
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
                    sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: TrackerProxy.sharedInstance, filters: filters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                    expect(sut.currentActiveFilters?.selectedCategories) == []
                }
                it("has firstDate no nil (more than one time in Letgo)") {
                    keyValueStorage[.sessionNumber] =  2
                    sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: TrackerProxy.sharedInstance, filters: filters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
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
                    sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: TrackerProxy.sharedInstance, filters: filters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
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
            
            context("Product list VM succeeded retrieving products") {
                var mockTracker: MockTracker!
                var productListViewModel: ProductListViewModel!
                
                beforeEach {
                    mockTracker = MockTracker()
                    productListViewModel = ProductListViewModel(requester: MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20))
                }
               
                context("with no filter and no search") {
                    beforeEach {
                        var userFilters = ProductFilters()
                        userFilters.selectedCategories = []
                        let searchType: SearchType? = nil
                
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: mockTracker, searchType: searchType, filters: userFilters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                        sut.productListVM(productListViewModel, didSucceedRetrievingProductsPage: 0, hasProducts: true)
                    }
                    it("fires product list event") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.productList]
                    }
                    it("fires product list event and feed source parameter is .home") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "home"
                    }
                }
                
                context("with search but no filter") {
                    beforeEach {
                        var userFilters = ProductFilters()
                        userFilters.selectedCategories = []
                        let searchType: SearchType = .user(query: "iphone")
                        
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: mockTracker, searchType: searchType, filters: userFilters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                        sut.productListVM(productListViewModel, didSucceedRetrievingProductsPage: 0, hasProducts: true)
                    }
                    it("fires product list event and search complete") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.productList, .searchComplete]
                    }
                    it("fires product list event and feed source parameter is .search") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "search"
                    }
                }
                
                context("with filter but no search") {
                    beforeEach {
                        var userFilters = ProductFilters()
                        userFilters.selectedCategories = [.motorsAndAccessories]
                        let searchType: SearchType? = nil
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: mockTracker, searchType: searchType, filters: userFilters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                        sut.productListVM(productListViewModel, didSucceedRetrievingProductsPage: 0, hasProducts: true)
                    }
                    it("fires product list event") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.productList]
                    }
                    it("fires product list event and feed source parameter is .filter") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "filter"
                    }
                }
                
                context("with filter & search") {
                    beforeEach {
                        var userFilters = ProductFilters()
                        userFilters.selectedCategories = [.motorsAndAccessories]
                        let searchType: SearchType = .user(query: "iphone")
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository, suggestedSearchesRepository: Core.suggestedSearchesRepository, listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository, locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: mockTracker, searchType: searchType, filters: userFilters, keyValueStorage: keyValueStorage, featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                        sut.productListVM(productListViewModel, didSucceedRetrievingProductsPage: 0, hasProducts: true)
                    }
                    it("fires product list event and search complete") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.productList, .searchComplete]
                    }
                    it("fires product list event and feed source parameter is .search&filter") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "search&filter"
                    }
                }
                
                context("with search collection") {
                    beforeEach {
                        var userFilters = ProductFilters()
                        userFilters.selectedCategories = []
                        let searchType: SearchType = .collection(type: .You, query: "iphone")
                        sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository,
                                                    suggestedSearchesRepository: Core.suggestedSearchesRepository,
                                                    listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository,
                                                    locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: mockTracker,
                                                    searchType: searchType, filters: userFilters, keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                        sut.productListVM(productListViewModel, didSucceedRetrievingProductsPage: 0, hasProducts: true)
                    }
                    it("fires product list event") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.productList]
                    }
                    it("fires product list event and feed source parameter is .collection") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "collection"
                    }
                }
            }
            context("Product list VM failed retrieving products") {
                var mockTracker: MockTracker!
                var productListViewModel: ProductListViewModel!
                
                beforeEach {
                    mockTracker = MockTracker()
                    productListViewModel = ProductListViewModel(requester: MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20))
                    sut = MainProductsViewModel(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository,
                                                suggestedSearchesRepository: Core.suggestedSearchesRepository,
                                                listingRepository: Core.listingRepository, monetizationRepository: Core.monetizationRepository,
                                                locationManager: Core.locationManager, currencyHelper: Core.currencyHelper, tracker: mockTracker,
                                                searchType: nil, filters: ProductFilters(), keyValueStorage: keyValueStorage,
                                                featureFlags: mockFeatureFlags, bubbleTextGenerator: DistanceBubbleTextGenerator())
                }
                
                context("with too many requests") {
                    beforeEach {
                       sut.productListMV(productListViewModel, didFailRetrievingProductsPage: 0, hasProducts: false, error:.tooManyRequests)
                    }
                    it("fires empty-state-error") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.emptyStateError]
                    }
                    it("fires empty-state-error with .unknown") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["reason"] as? String) == "unknown"
                    }
                }
                context("with internet connection error") {
                    beforeEach {
                        sut.productListMV(productListViewModel, didFailRetrievingProductsPage: 0, hasProducts: false, error:.network(errorCode: -1, onBackground: false))
                    }
                    it("fires empty-state-error") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.emptyStateError]
                    }
                    it("fires empty-state-error with .no-internet-connection") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["reason"] as? String) == "no-internet-connection"
                    }
                }
            }
        }
    }
}

