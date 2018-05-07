//
//  MainListingsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 18/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class MainListingsViewModelSpec: QuickSpec {
    override func spec() {
        
        describe("MainListingsViewModelSpec") {
            
            var sut: MainListingsViewModel!
            var keyValueStorage: KeyValueStorage!
            var filters: ListingFilters!
            var mockFeatureFlags: MockFeatureFlags!
            
            beforeEach {
                keyValueStorage = KeyValueStorage()
                mockFeatureFlags = MockFeatureFlags()
                filters = ListingFilters()
            }
            
            context("Initialization") {
                it("has firstDate nil (first time in Letgo)") {
                    keyValueStorage[.sessionNumber] = 1
                    sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                myUserRepository: Core.myUserRepository,
                                                searchRepository: Core.searchRepository,
                                                listingRepository: Core.listingRepository,
                                                monetizationRepository: Core.monetizationRepository,
                                                categoryRepository: Core.categoryRepository,
                                                searchAlertsRepository: Core.searchAlertsRepository,
                                                locationManager: Core.locationManager,
                                                currencyHelper: Core.currencyHelper,
                                                tracker: TrackerProxy.sharedInstance,
                                                searchType: nil,
                                                filters: filters,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: mockFeatureFlags,
                                                bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                chatWrapper: MockChatWrapper())
                    expect(sut.currentActiveFilters?.selectedCategories) == []
                }
                it("has firstDate no nil (more than one time in Letgo)") {
                    keyValueStorage[.sessionNumber] =  2
                    sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                myUserRepository: Core.myUserRepository,
                                                searchRepository: Core.searchRepository,
                                                listingRepository: Core.listingRepository,
                                                monetizationRepository: Core.monetizationRepository,
                                                categoryRepository: Core.categoryRepository,
                                                searchAlertsRepository: Core.searchAlertsRepository,
                                                locationManager: Core.locationManager,
                                                currencyHelper: Core.currencyHelper,
                                                tracker: TrackerProxy.sharedInstance,
                                                searchType: nil,
                                                filters: filters,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: mockFeatureFlags,
                                                bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                chatWrapper: MockChatWrapper())
                    expect(sut.currentActiveFilters?.selectedCategories) == []
                }
            }
            
            context("Filter edition") {
                var userFilters: ListingFilters!
                var filtersViewModel: FiltersViewModel!
                
                beforeEach {
                    filtersViewModel = FiltersViewModel()
                    userFilters = ListingFilters()
                    userFilters.distanceRadius = 50
                    userFilters.selectedCategories = []
                }
                beforeEach {
                    keyValueStorage[.sessionNumber] = 1
                    sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                myUserRepository: Core.myUserRepository,
                                                searchRepository: Core.searchRepository,
                                                listingRepository: Core.listingRepository,
                                                monetizationRepository: Core.monetizationRepository,
                                                categoryRepository: Core.categoryRepository,
                                                searchAlertsRepository: Core.searchAlertsRepository,
                                                locationManager: Core.locationManager,
                                                currencyHelper: Core.currencyHelper,
                                                tracker: TrackerProxy.sharedInstance,
                                                searchType: nil,
                                                filters: userFilters,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: mockFeatureFlags,
                                                bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                chatWrapper: MockChatWrapper())
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
                        let userFiltersRemoved = ListingFilters()
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
                var listingListViewModel: ListingListViewModel!
                
                beforeEach {
                    mockTracker = MockTracker()
                    listingListViewModel = ListingListViewModel(requester: MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20))
                }
               
                context("with no filter and no search") {
                    beforeEach {
                        var userFilters = ListingFilters()
                        userFilters.selectedCategories = []
                        let searchType: SearchType? = nil
                        sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                    myUserRepository: Core.myUserRepository,
                                                    searchRepository: Core.searchRepository,
                                                    listingRepository: Core.listingRepository,
                                                    monetizationRepository: Core.monetizationRepository,
                                                    categoryRepository: Core.categoryRepository,
                                                    searchAlertsRepository: Core.searchAlertsRepository,
                                                    locationManager: Core.locationManager,
                                                    currencyHelper: Core.currencyHelper,
                                                    tracker: mockTracker,
                                                    searchType: searchType,
                                                    filters: userFilters,
                                                    keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags,
                                                    bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                    chatWrapper: MockChatWrapper())
                        sut.listingListVM(listingListViewModel, didSucceedRetrievingListingsPage: 0, withResultsCount: Int.random(), hasListings: true)
                    }
                    it("fires product list event") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.listingList]
                    }
                    it("fires product list event and feed source parameter is .home") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "home"
                    }
                }
                
                context("with search but no filter") {
                    beforeEach {
                        var userFilters = ListingFilters()
                        userFilters.selectedCategories = []
                        let searchType: SearchType = .user(query: "iphone")
                        sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                    myUserRepository: Core.myUserRepository,
                                                    searchRepository: Core.searchRepository,
                                                    listingRepository: Core.listingRepository,
                                                    monetizationRepository: Core.monetizationRepository,
                                                    categoryRepository: Core.categoryRepository,
                                                    searchAlertsRepository: Core.searchAlertsRepository,
                                                    locationManager: Core.locationManager,
                                                    currencyHelper: Core.currencyHelper,
                                                    tracker: mockTracker,
                                                    searchType: searchType,
                                                    filters: userFilters,
                                                    keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags,
                                                    bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                    chatWrapper: MockChatWrapper())
                        sut.listingListVM(listingListViewModel, didSucceedRetrievingListingsPage: 0, withResultsCount: Int.random(), hasListings: true)
                    }
                    it("fires listing list event and search complete") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.listingList, .searchComplete]
                    }
                    it("fires listing list event and feed source parameter is .search") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "search"
                    }
                }
                
                context("with filter but no search") {
                    beforeEach {
                        var userFilters = ListingFilters()
                        userFilters.selectedCategories = [.motorsAndAccessories]
                        let searchType: SearchType? = nil
                        sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                    myUserRepository: Core.myUserRepository,
                                                    searchRepository: Core.searchRepository,
                                                    listingRepository: Core.listingRepository,
                                                    monetizationRepository: Core.monetizationRepository,
                                                    categoryRepository: Core.categoryRepository,
                                                    searchAlertsRepository: Core.searchAlertsRepository,
                                                    locationManager: Core.locationManager,
                                                    currencyHelper: Core.currencyHelper,
                                                    tracker: mockTracker,
                                                    searchType: searchType,
                                                    filters: userFilters,
                                                    keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags,
                                                    bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                    chatWrapper: MockChatWrapper())
                        sut.listingListVM(listingListViewModel, didSucceedRetrievingListingsPage: 0, withResultsCount: Int.random(), hasListings: true)
                    }
                    it("fires product list event") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.listingList]
                    }
                    it("fires product list event and feed source parameter is .filter") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "filter"
                    }
                }
                
                context("with filter & search") {
                    beforeEach {
                        var userFilters = ListingFilters()
                        userFilters.selectedCategories = [.motorsAndAccessories]
                        let searchType: SearchType = .user(query: "iphone")
                        sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                    myUserRepository: Core.myUserRepository,
                                                    searchRepository: Core.searchRepository,
                                                    listingRepository: Core.listingRepository,
                                                    monetizationRepository: Core.monetizationRepository,
                                                    categoryRepository: Core.categoryRepository,
                                                    searchAlertsRepository: Core.searchAlertsRepository,
                                                    locationManager: Core.locationManager,
                                                    currencyHelper: Core.currencyHelper,
                                                    tracker: mockTracker,
                                                    searchType: searchType,
                                                    filters: userFilters,
                                                    keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags,
                                                    bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                    chatWrapper: MockChatWrapper())
                        sut.listingListVM(listingListViewModel, didSucceedRetrievingListingsPage: 0, withResultsCount: Int.random(), hasListings: true)
                    }
                    it("fires product list event and search complete") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.listingList, .searchComplete]
                    }
                    it("fires product list event and feed source parameter is .search&filter") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "search&filter"
                    }
                }
                
                context("with search collection") {
                    beforeEach {
                        var userFilters = ListingFilters()
                        userFilters.selectedCategories = []
                        let searchType: SearchType = .collection(type: .selectedForYou, query: "iphone")
                        sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                    myUserRepository: Core.myUserRepository,
                                                    searchRepository: Core.searchRepository,
                                                    listingRepository: Core.listingRepository,
                                                    monetizationRepository: Core.monetizationRepository,
                                                    categoryRepository: Core.categoryRepository,
                                                    searchAlertsRepository: Core.searchAlertsRepository,
                                                    locationManager: Core.locationManager,
                                                    currencyHelper: Core.currencyHelper,
                                                    tracker: mockTracker,
                                                    searchType: searchType,
                                                    filters: userFilters,
                                                    keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags,
                                                    bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                    chatWrapper: MockChatWrapper())
                        sut.listingListVM(listingListViewModel, didSucceedRetrievingListingsPage: 0, withResultsCount: Int.random(), hasListings: true)
                    }
                    it("fires product list event") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.listingList]
                    }
                    it("fires product list event and feed source parameter is .collection") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["feed-source"] as? String) == "collection"
                    }
                }
                
                context("with filter real estate") {
                    var listings: [ListingCellModel]!
                    var totalListings: [ListingCellModel]?
                    beforeEach {
                        var userFilters = ListingFilters()
                        userFilters.selectedCategories = [.realEstate]
                        let searchType: SearchType? = nil
                        listings = MockProduct.makeMocks(count: 20).map { ListingCellModel.listingCell(listing: .product($0)) }
                        sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                    myUserRepository: Core.myUserRepository,
                                                    searchRepository: Core.searchRepository,
                                                    listingRepository: Core.listingRepository,
                                                    monetizationRepository: Core.monetizationRepository,
                                                    categoryRepository: Core.categoryRepository,
                                                    searchAlertsRepository: Core.searchAlertsRepository,
                                                    locationManager: Core.locationManager,
                                                    currencyHelper: Core.currencyHelper,
                                                    tracker: mockTracker,
                                                    searchType: searchType,
                                                    filters: userFilters,
                                                    keyValueStorage: keyValueStorage,
                                                    featureFlags: mockFeatureFlags,
                                                    bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                    chatWrapper: MockChatWrapper())
                    }
                    
                    context("receives listing page with promo cell not active") {
                        beforeEach {
                            totalListings = sut.vmProcessReceivedListingPage(listings, page: 0)
                        }
                        
                        it("first cell is not promo") {
                            expect({
                                guard let firstListing = totalListings?.first,
                                    case .promo = firstListing else {
                                        return .succeeded
                                }
                                return .failed(reason: "wrong cell type")
                            }).to(succeed())
                        }
                    }
                    
                    context("receives listing page with promo cell active") {
                        beforeEach {
                            mockFeatureFlags.realEstatePromoCell = .active
                            totalListings = sut.vmProcessReceivedListingPage(listings, page: 0)
                        }
                        
                        it("first cell is promo") {
                            expect({
                                guard let firstListing = totalListings?.first,
                                    case .promo = firstListing else {
                                    return .failed(reason: "wrong cell type")
                                }
                                return .succeeded
                            }).to(succeed())
                        }
                    }
                    
                }
            }
            
            context("with filter cars") {

                beforeEach {
                    var filters = ListingFilters()
                    filters.selectedCategories = [.cars]
                    filters.carSellerTypes = [.user]
                    sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                myUserRepository: Core.myUserRepository,
                                                searchRepository: Core.searchRepository,
                                                listingRepository: Core.listingRepository,
                                                monetizationRepository: Core.monetizationRepository,
                                                categoryRepository: Core.categoryRepository,
                                                searchAlertsRepository: Core.searchAlertsRepository,
                                                locationManager: Core.locationManager,
                                                currencyHelper: Core.currencyHelper,
                                                tracker: TrackerProxy.sharedInstance,
                                                searchType: nil,
                                                filters: filters,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: mockFeatureFlags,
                                                bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                chatWrapper: MockChatWrapper())
                }
                
                context("cars new backend active") {
                    beforeEach {
                        mockFeatureFlags.searchCarsIntoNewBackend = .active
                    }
                    
                    context("car seller type multiple selection") {
                        beforeEach {
                            mockFeatureFlags.filterSearchCarSellerType = .variantA
                        }
                        it("has right tags") {
                            expect(sut.primaryTags).to(contain(.carSellerType(type: .user,
                                                                              name: LGLocalizedString.filtersCarSellerTypePrivate)))
                        }
                        
                    }
                    
                    context("car seller type single selection") {
                        beforeEach {
                            mockFeatureFlags.filterSearchCarSellerType = .variantC
                        }
                        it("has NOT All tag") {
                            expect(sut.primaryTags).toNot(contain(.carSellerType(type: .user,
                                                                                 name: LGLocalizedString.filtersCarSellerTypeAll)))
                        }
                    }
                }
            }
            
            context("Product list VM failed retrieving products") {
                var mockTracker: MockTracker!
                var listingListViewModel: ListingListViewModel!
                
                beforeEach {
                    mockTracker = MockTracker()
                    listingListViewModel = ListingListViewModel(requester: MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20))
                    sut = MainListingsViewModel(sessionManager: Core.sessionManager,
                                                myUserRepository: Core.myUserRepository,
                                                searchRepository: Core.searchRepository,
                                                listingRepository: Core.listingRepository,
                                                monetizationRepository: Core.monetizationRepository,
                                                categoryRepository: Core.categoryRepository,
                                                searchAlertsRepository: Core.searchAlertsRepository,
                                                locationManager: Core.locationManager,
                                                currencyHelper: Core.currencyHelper,
                                                tracker: mockTracker,
                                                searchType: nil,
                                                filters: filters,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: mockFeatureFlags,
                                                bubbleTextGenerator: DistanceBubbleTextGenerator(),
                                                chatWrapper: MockChatWrapper())
                }
                
                context("with too many requests") {
                    beforeEach {
                       sut.listingListMV(listingListViewModel, didFailRetrievingListingsPage: 0, hasListings: false, error:.tooManyRequests)
                    }
                    it("fires empty-state-error") {
                        let eventNames = mockTracker.trackedEvents.flatMap { $0.name }
                        expect(eventNames) == [.emptyStateError]
                    }
                    it("fires empty-state-error with .tooManyRequests") {
                        let eventParams = mockTracker.trackedEvents.flatMap { $0.params }.first
                        expect(eventParams?.stringKeyParams["reason"] as? String) == "too-many-requests"
                    }
                }
                context("with internet connection error") {
                    beforeEach {
                        sut.listingListMV(listingListViewModel, didFailRetrievingListingsPage: 0, hasListings: false, error:.network(errorCode: -1, onBackground: false))
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

