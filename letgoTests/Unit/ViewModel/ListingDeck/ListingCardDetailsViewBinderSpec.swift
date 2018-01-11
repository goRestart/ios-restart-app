//
//  ListingCardDetailsViewBinderSpec.swift
//  letgoTests
//
//  Created by Facundo Menzella on 08/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble

class ListingCardDetailsViewBinderSpec: QuickSpec {

    override func spec() {
        var sut: ListingCardDetailsViewBinder!
        var mockListingDetailsVM: MockListingCardDetailsViewModel!
        var mockListingDetailsView: MockListingCardDetailsView!

        describe("PhotoViewerViewControllerBinderSpec") {
            beforeEach {
                sut = ListingCardDetailsViewBinder()
                
                mockListingDetailsVM = MockListingCardDetailsViewModel()
                mockListingDetailsView = MockListingCardDetailsView()
                sut.detailsView = mockListingDetailsView

                sut.bind(to: mockListingDetailsVM)
            }

            afterEach {
                mockListingDetailsView.resetAllVariables()
            }

            context("cardProductInfo updates") {
                beforeEach {
                    let listing = Listing.makeMock()
                    mockListingDetailsVM.rx_cardProductInfo.value = ListingVMProductInfo(listing: listing,
                                                                                         isAutoTranslated: true,
                                                                                         distance: nil,
                                                                                         freeModeAllowed: true)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithProductInfoCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
                it("disableStatsView not called") {
                    expect(mockListingDetailsView.isDisabledStatsViewCalled).toEventually(equal(0))
                }
            }

            context("cardProductStats updates with views above minimum") {
                beforeEach {
                    let aboveMinimumViews = 5 + Int.makeRandom(min: 0, max: 100)
                    let belowMinimumFavs = Int.random(0, 4)
                    mockListingDetailsVM.rx_cardProductStats.value = MockListingStats(viewsCount: aboveMinimumViews,
                                                                                      favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
                it("disableStatsView not called") {
                    expect(mockListingDetailsView.isDisabledStatsViewCalled).toEventually(equal(0))
                }
            }

            context("cardProductStats updates with favourites above minimum") {
                beforeEach {
                    let belowMinimumViews = Int.random(0, 4)
                    let aboveMinimumFavs = 5 + Int.makeRandom(min: 0, max: 100)
                    mockListingDetailsVM.rx_cardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                      favouritesCount: aboveMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
                it("disableStatsView not called") {
                    expect(mockListingDetailsView.isDisabledStatsViewCalled).toEventually(equal(0))
                }
            }

            context("cardProductStats updates with both stats above minimum") {
                beforeEach {
                    let belowMinimumViews = Int.random(0, 4)
                    let belowMinimumFavs = Int.random(0, 4)

                    mockListingDetailsVM.rx_cardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                      favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
                it("disableStatsView not called") {
                    expect(mockListingDetailsView.isDisabledStatsViewCalled).toEventually(equal(1))
                }
            }

            context("cardProductStats updates with both stats above minimum but with creation date") {
                beforeEach {
                    let listing = Listing.makeMock()
                    mockListingDetailsVM.rx_cardProductInfo.value = ListingVMProductInfo(listing: listing,
                                                                                         isAutoTranslated: true,
                                                                                         distance: nil,
                                                                                         freeModeAllowed: true)
                    let belowMinimumViews = Int.random(0, 4)
                    let belowMinimumFavs = Int.random(0, 4)
                    mockListingDetailsVM.rx_cardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                      favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
                it("disableStatsView not called") {
                    expect(mockListingDetailsView.isDisabledStatsViewCalled).toEventually(equal(0))
                }
            }

            context("cardSocialMessage updates") {
                beforeEach {
                    let listing = Listing.makeMock()
                    mockListingDetailsVM.rx_cardSocialMessage.value = ListingSocialMessage(listing: listing,
                                                                                           fallbackToStore: true)
                }
                it("the proper populate method is called first empty and then with value") {
                    expect(mockListingDetailsView.isPopulateWithSocialMessageCalled).toEventually(equal(2))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
            }

            context("we dealloc the view") {
                beforeEach {
                    mockListingDetailsView = MockListingCardDetailsView()
                }
                it("and the binder's viewcontroller reference dies too (so weak)") {
                    expect(sut.detailsView).toEventually(beNil())
                }
            }
        }
    }
}

private class MockListingStats: ListingStats {
    var viewsCount: Int = 0
    var favouritesCount: Int = 0

    init(viewsCount: Int, favouritesCount: Int) {
        self.viewsCount = viewsCount
        self.favouritesCount = favouritesCount
    }
}

private class MockListingCardDetailsViewModel:  ListingCardDetailsViewModel {
    var cardProductInfo: Observable<ListingVMProductInfo?> { return rx_cardProductInfo.asObservable() }
    var cardProductStats: Observable<ListingStats?> { return rx_cardProductStats.asObservable() }
    var cardSocialSharer: SocialSharer = SocialSharer()
    var cardSocialMessage: Observable<SocialMessage?> { return rx_cardSocialMessage.asObservable() }

    let rx_cardProductInfo: Variable<ListingVMProductInfo?> = Variable<ListingVMProductInfo?>(nil)
    let rx_cardProductStats: Variable<ListingStats?> =  Variable<ListingStats?>(nil)
    let rx_cardSocialMessage: Variable<SocialMessage?> = Variable<SocialMessage?>(nil)
}

private class MockListingCardDetailsView: ListingCardDetailsViewType {

    var isPopulateWithProductInfoCalled: Int = 0
    var isPopulateWithSocialSharerCalled: Int = 0
    var isPopulateWithSocialMessageCalled: Int = 0
    var isPopulateWithListingStatsCalled: Int = 0
    var isDisabledStatsViewCalled: Int = 0

    func resetAllVariables() {
        isPopulateWithProductInfoCalled = 0
        isPopulateWithSocialSharerCalled = 0
        isPopulateWithSocialMessageCalled = 0
        isPopulateWithListingStatsCalled = 0
        isDisabledStatsViewCalled = 0
    }

    func disableStatsView() {
        isDisabledStatsViewCalled += 1
    }

    func populateWith(productInfo: ListingVMProductInfo) {
        isPopulateWithProductInfoCalled += 1
    }

    func populateWith(socialSharer: SocialSharer) {
        isPopulateWithSocialSharerCalled += 1
    }

    func populateWith(socialMessage: SocialMessage?) {
        isPopulateWithSocialMessageCalled += 1
    }

    func populateWith(listingStats: ListingStats, postedDate: Date?) {
        isPopulateWithListingStatsCalled += 1
    }

}

