@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import LGComponents
import Result

final class FeedViewModelSpec: BaseViewModelSpec {
    
    override func spec() {

        var subject: FeedViewModel?
        
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
        
        describe("didTapSeeAll- with nil Navigator ") {
            let feedWireframeMock: FeedWireframeMock = FeedWireframeMock()
            
            beforeEach {
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
                subject?.didTapSeeAll(page: .user(query: "CommanderKeen"))
            }
            
            it("should open the pro feed") {
                expect(feedWireframeMock.openProFeedWasCalled.0) == true
            }
            
            it("should have search type as nil due to navigator == nil") {
                expect(feedWireframeMock.openProFeedWasCalled.1?.query).to(beNil())
            }
            
            it("should have navigator == nil") {
                expect(feedWireframeMock.openProFeedWasCalled.2).to(beNil())
            }
        }

        describe("didTapSeeAll- with Navigator") {
            let feedWireframeMock: FeedWireframeMock = FeedWireframeMock()
            
            beforeEach {
                let coordinator = MainTabCoordinator()
                subject = self.makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
                subject?.wireframe = feedWireframeMock
                subject?.navigator = coordinator
                subject?.didTapSeeAll(page: .user(query: "CommanderKeen"))
            }
            
            it("should open the pro feed") {
                expect(feedWireframeMock.openProFeedWasCalled.0) == true
            }
            
            it("should have search type") {
                expect(feedWireframeMock.openProFeedWasCalled.1?.query) == "CommanderKeen"
            }
            
            it("should have navigator not be nil") {
                expect(feedWireframeMock.openProFeedWasCalled.2).toNot(beNil())
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
        return FeedViewModel(searchType: nil,
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
        var openLocationWasCalled: Bool = false
        var showPushPermissionsAlertWasCalled: Bool = false
        var openMapWasCalled: Bool = false
        var openAppInviteWasCalled: (Bool, String?, String?) = (true, nil, nil)
        var openProFeedWasCalled: (state: Bool, searchType: SearchType?, navigator: MainTabNavigator?, andFilters: ListingFilters?) = (true, nil, nil, nil)
        var openClassicFeedWasCalled: Bool = true
        
        func openFilters(withListingFilters listingFilters: ListingFilters, filtersVMDataDelegate: FiltersViewModelDataDelegate?) {
            openFiltersWasCalled = (true, listingFilters)
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
        
        func openAppInvite(myUserId: String?, myUserName: String?) {
            openAppInviteWasCalled = (true, myUserId, myUserName)
        }
        
        func openProFeed(navigator: MainTabNavigator?, withSearchType searchType: SearchType, andFilters filters: ListingFilters) {
            openProFeedWasCalled = (true, searchType, navigator, filters)
        }
        
        func openClassicFeed(navigator: MainTabNavigator, withSearchType searchType: SearchType, listingFilters: ListingFilters) {
            openClassicFeedWasCalled = true
        }
    }
}

