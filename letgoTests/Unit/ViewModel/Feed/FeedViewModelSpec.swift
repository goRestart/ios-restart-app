@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import LGComponents
import Result

final class FeedViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        
        var subject: FeedViewModel?
        
        beforeEach {
            subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
        }
        
        describe("showFilters") {
            let feedWireframeMock: FeedWireframeMock = FeedWireframeMock()
            
            beforeEach {
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
                subject?.showFilters()
            }
            
            it("should open the filters") {
                expect(feedWireframeMock.openFiltersWasCalled.0) == true
            }
            
            it("should send the correct parameters") {
                expect(feedWireframeMock.openFiltersWasCalled.1).toNot(beNil())
            }
        }
        
        describe("openInvite") {
            let feedWireframeMock: FeedWireframeMock = FeedWireframeMock()
            
            beforeEach {
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
                subject?.openInvite()
            }
            
            it("should open the app invite") {
                expect(feedWireframeMock.openAppInviteWasCalled.0) == true
            }
        }
        
        describe("didTapSeeAll") {
            var feedWireframeMock: FeedWireframeMock?
            let coordinator = MainTabCoordinator()
            
            beforeEach {
                feedWireframeMock = FeedWireframeMock()
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
            }
            
            context("when the navigator is not nil") {
                beforeEach {
                    subject?.navigator = coordinator
                    subject?.didTapSeeAll(page: .user(query: "CommanderKeen"), section: 0, identifier: "DopefishSection")
                }
                
                it("should open the pro feed") {
                    expect(feedWireframeMock?.openProFeedWasCalled.0) == true
                }
                
                it("should have a beautiful search type") {
                    expect(feedWireframeMock?.openProFeedWasCalled.searchType).toNot(beNil())
                }
                
                it("should have the correct search type") {
                    expect(feedWireframeMock?.openProFeedWasCalled.1?.query) == "CommanderKeen"
                }
            }
            
            context("when the navigator is nil") {
                beforeEach {
                    subject?.navigator = nil
                    subject?.didTapSeeAll(page: .user(query: "CommanderKeen"), section: 0, identifier: "DopefishSection")
                }
                
                it("should NOT open the pro feed") {
                    expect(feedWireframeMock?.openProFeedWasCalled.0) == false
                }
                
                it("should have search type as nil due to navigator == nil") {
                    expect(feedWireframeMock?.openProFeedWasCalled.1?.query).to(beNil())
                }
                
                it("should have navigator == nil") {
                    expect(feedWireframeMock?.openProFeedWasCalled.searchType).to(beNil())
                }
            }
        }
        
        describe("showFilters") {
            let feedWireframeMock: FeedWireframeMock = FeedWireframeMock()
            
            beforeEach {
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
                subject?.showFilters()
            }
            
            it("should open the filters") {
                expect(feedWireframeMock.openFiltersWasCalled.0) == true
            }
            
            it("should send the correct parameters") {
                expect(feedWireframeMock.openFiltersWasCalled.1).toNot(beNil())
            }
        }
        
        describe("openInvite") {
            let feedWireframeMock: FeedWireframeMock = FeedWireframeMock()
            
            beforeEach {
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
                subject?.openInvite()
            }
            
            it("should open the app invite") {
                expect(feedWireframeMock.openAppInviteWasCalled.0) == true
            }
        }
        
        describe("viewModelDidUpdateFilters") {
            var feedWireframeMock: FeedWireframeMock?
            var filters: ListingFilters = ListingFilters()
            var coordinator: MainTabCoordinator?
            
            beforeEach {
                coordinator = MainTabCoordinator()
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                feedWireframeMock = FeedWireframeMock()
                subject?.wireframe = feedWireframeMock
                subject?.navigator = coordinator
                subject?.viewModelDidUpdateFilters(FiltersViewModel(), filters: filters)
            }
            
            context("when the filters are the default") {
                beforeEach {
                    filters = ListingFilters()
                }
                
                it("should do nothing") {
                    expect(feedWireframeMock?.openClassicFeedWasCalled.state) == false
                }
            }
            
            context("when the filters are NOT the defaults") {
                
                beforeEach {
                    filters = ListingFilters.makeMock()
                }
                
                context("and the navigator does not exists") {
                    beforeEach {
                        subject?.navigator = nil
                    }
                    
                    it("should do nothing") {
                        expect(feedWireframeMock?.openClassicFeedWasCalled.state) == false
                    }
                }
                
                context("and the navigator exists") {
                    context("and has many filters") {
                        
                        beforeEach {
                            filters = ListingFilters.makeMock()
                        }
                        
                        it("should call the correct method") {
                            expect(feedWireframeMock?.openClassicFeedWasCalled.state) == true
                        }
                        
                        it("should contains the correct parameters") {
                            expect(feedWireframeMock?.openClassicFeedWasCalled.navigator).toNot(beNil())
                            expect(feedWireframeMock?.openClassicFeedWasCalled.searchType).toNot(beNil())
                            expect(feedWireframeMock?.openClassicFeedWasCalled.shouldCloseOnRemoveAllFilters) == true
                        }
                    }
                    
                    context("and only has place filter") {
                        
                        beforeEach {
                            feedWireframeMock = FeedWireframeMock()
                            filters = ListingFilters()
                            filters.place = Place(placeId: nil, placeResumedData: nil)
                        }
                        
                        it("should call the correct method") {
                            expect(feedWireframeMock?.openClassicFeedWasCalled.state) == false
                        }
                    }
                    
                }
            }
        }
        
        describe("openSearches") {
            var wireframe: FeedWireframeMock?
            let navigator: MainTabCoordinator = MainTabCoordinator()
            
            beforeEach {
                wireframe = FeedWireframeMock()
                subject?.wireframe = wireframe
            }
            
            context("when the navigator is nil") {
                beforeEach {
                    subject?.navigator = nil
                    subject?.openSearches()
                }
                
                it("should not call the correct method") {
                    expect(wireframe?.openSearchesWasCalled) == false
                }
            }
            
            context("when the navigator is NOT nil") {
                beforeEach {
                    subject?.navigator = navigator
                    subject?.openSearches()
                }
                
                it("should call the correct and beautiful method") {
                    expect(wireframe?.openSearchesWasCalled) == true
                }
            }
        }
        
    }
}

//  MARK: - Helpers

private extension FeedViewModelSpec {
    
    func makeFeedViewModel(withFeedResult feedResult: FeedResult) -> FeedViewModel {
        let locationManager = MockLocationManager()
        let featureFlags = MockFeatureFlags()
        let mockFeedRepository = MockFeedRepository()
        mockFeedRepository.indexParamsResult = feedResult
        mockFeedRepository.indexUrlResult = feedResult
        let location = LGLocation.makeMock().updating(postalAddress: PostalAddress(address: "",
                                                                                   city: "",
                                                                                   zipCode: "",
                                                                                   state: "",
                                                                                   countryCode: "US",
                                                                                   country: "US"))
        locationManager.currentLocation = location
        
        return FeedViewModel(searchType: SearchType.user(query: "BatMan"),
                             filters: ListingFilters.makeMock(),
                             bubbleTextGenerator: DistanceBubbleTextGenerator(locationManager: locationManager, featureFlags: featureFlags),
                             myUserRepository: MockMyUserRepository.makeMock(),
                             tracker: MockTracker(),
                             pushPermissionsManager: MockPushPermissionsManager(),
                             application: MockApplication(),
                             locationManager: locationManager,
                             featureFlags: featureFlags,
                             keyValueStorage: MockKeyValueStorage(),
                             deviceFamily: .iPhone6Plus)
    }
    
    class FeedWireframeMock: FeedNavigator {
        var openFiltersWasCalled: (state: Bool, listingFilters: ListingFilters?) = (false, nil)
        var openAffiliationChallengesWasCalled: Bool = false
        var openLocationWasCalled: Bool = false
        var showPushPermissionsAlertWasCalled: Bool = false
        var openMapWasCalled: Bool = false
        var openSearchesWasCalled: Bool = false
        var openAppInviteWasCalled: (Bool, String?, String?) = (false, nil, nil)
        var openProFeedWasCalled: (state: Bool, searchType: SearchType?, filters: ListingFilters?) = (false, nil, nil)
        var openClassicFeedWasCalled: (state: Bool, navigator: MainTabNavigator?, searchType: SearchType?, shouldCloseOnRemoveAllFilters: Bool?) = (false, nil, nil, nil)
        
        
        func openFilters(withListingFilters listingFilters: ListingFilters, filtersVMDataDelegate: FiltersViewModelDataDelegate?) {
            openFiltersWasCalled = (true, listingFilters)
        }
        
        func openAffiliationChallenges() {
            openAffiliationChallengesWasCalled = true
        }
        
        func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate) {
            openLocationWasCalled = true
        }
        
        func showPushPermissionsAlert(pushPermissionsManager: PushPermissionsManager, withPositiveAction positiveAction: @escaping (() -> Void), negativeAction: @escaping (() -> Void)) {
            showPushPermissionsAlertWasCalled = true
        }
        
        func openMap(navigator: ListingsMapNavigator, requester: ListingListMultiRequester, listingFilters: ListingFilters, locationManager: LocationManager) {
            openMapWasCalled = true
        }
        
        func openSearches(withSearchType searchType: SearchType?, onUserSearchCallback: ((SearchType) -> ())?) {
            openSearchesWasCalled = true
        }
        
        func openAppInvite(myUserId: String?, myUserName: String?) {
            openAppInviteWasCalled = (true, myUserId, myUserName)
        }
        
        func openClassicFeed(navigator: MainTabNavigator, withSearchType searchType: SearchType?, listingFilters: ListingFilters) {
            openClassicFeedWasCalled = (
                state: true,
                navigator: navigator,
                searchType: searchType,
                shouldCloseOnRemoveAllFilters: true
            )
        }
        
        func openProFeed(navigator: MainTabNavigator?, withSearchType searchType: SearchType, andFilters filters: ListingFilters) {
            openProFeedWasCalled = (state: true, searchType: searchType, filters: filters)
        }
        
        func openProFeed(navigator: MainTabNavigator?, withSearchType searchType: SearchType, andFilters filters: ListingFilters, andComingSectionPosition: UInt?, andComingSectionIdentifier: String?) {
            openProFeedWasCalled = (state: true, searchType: searchType, filters: filters)
        }
        
        func openClassicFeed(navigator: MainTabNavigator, withSearchType searchType: SearchType?, listingFilters: ListingFilters, shouldCloseOnRemoveAllFilters: Bool) {
            openClassicFeedWasCalled = (
                state: true,
                navigator: navigator,
                searchType: searchType,
                shouldCloseOnRemoveAllFilters: shouldCloseOnRemoveAllFilters
            )
        }

        func openClassicFeed(navigator: MainTabNavigator, withSearchType searchType: SearchType?, listingFilters: ListingFilters, shouldCloseOnRemoveAllFilters: Bool, tagsDelegate: MainListingsTagsDelegate?) {
            openClassicFeedWasCalled = (
                state: true,
                navigator: navigator,
                searchType: searchType,
                shouldCloseOnRemoveAllFilters: shouldCloseOnRemoveAllFilters
            )
        }

    }
}

