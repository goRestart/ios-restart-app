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
                    mockListingDetailsVM.rxCardProductInfo.value = ListingVMProductInfo(listing: listing,
                                                                                         isAutoTranslated: true,
                                                                                         distance: nil,
                                                                                         freeModeAllowed: true,
                                                                                         postingFlowType: .standard)
                    mockListingDetailsVM.rxCardShowExactLocationOnMap.value = true
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithProductInfoCalled).toEventually(equal(2))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
                it("show exact location on map changes") {
                    expect(mockListingDetailsView.showExactLocationOnMap).toEventually(beTrue())
                }
            }

            context("cardProductStats updates with views above minimum") {
                beforeEach {
                    let aboveMinimumViews = 5 + Int.makeRandom(min: 0, max: 100)
                    let belowMinimumFavs = Int.random(0, 4)
                    mockListingDetailsVM.rxCardProductStats.value = MockListingStats(viewsCount: aboveMinimumViews,
                                                                                      favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
            }

            context("cardProductStats updates with favourites above minimum") {
                beforeEach {
                    let belowMinimumViews = Int.random(0, 4)
                    let aboveMinimumFavs = 5 + Int.makeRandom(min: 0, max: 100)
                    mockListingDetailsVM.rxCardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                      favouritesCount: aboveMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
            }

            context("cardProductStats updates with both stats above minimum and no creation date") {
                beforeEach {
                    let belowMinimumViews = Int.random(0, 4)
                    let belowMinimumFavs = Int.random(0, 4)
                    mockListingDetailsVM.rxCardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                      favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
            }

            context("cardProductStats updates with both stats above minimum with creation date") {
                beforeEach {
                    let belowMinimumViews = Int.random(0, 4)
                    let belowMinimumFavs = Int.random(0, 4)
                    mockListingDetailsVM.rxCardProductInfo.value = ListingVMProductInfo(listing: Listing.makeMock(),
                                                                                        isAutoTranslated: true,
                                                                                        distance: nil,
                                                                                        freeModeAllowed: true,
                                                                                        postingFlowType: .standard)
                    mockListingDetailsVM.rxCardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                     favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
            }

            context("cardProductStats updates with both stats above minimum but with creation date") {
                beforeEach {
                    let listing = Listing.makeMock()
                    mockListingDetailsVM.rxCardProductInfo.value = ListingVMProductInfo(listing: listing,
                                                                                         isAutoTranslated: true,
                                                                                         distance: nil,
                                                                                         freeModeAllowed: true,
                                                                                         postingFlowType: .standard)
                    let belowMinimumViews = Int.random(0, 4)
                    let belowMinimumFavs = Int.random(0, 4)
                    mockListingDetailsVM.rxCardProductStats.value = MockListingStats(viewsCount: belowMinimumViews,
                                                                                      favouritesCount: belowMinimumFavs)
                }
                it("the proper populate method is called") {
                    expect(mockListingDetailsView.isPopulateWithListingStatsCalled).toEventually(equal(1))
                }
                it("social sharer is set") {
                    expect(mockListingDetailsView.isPopulateWithSocialSharerCalled).toEventually(equal(1))
                }
            }

            context("cardSocialMessage updates") {
                beforeEach {
                    mockListingDetailsVM.rxCardSocialMessage.value = MockListingSocialMessage()
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
    var cardProductInfo: Observable<ListingVMProductInfo?> { return rxCardProductInfo.asObservable() }
    var cardProductStats: Observable<ListingStats?> { return rxCardProductStats.asObservable() }
    var cardSocialSharer: SocialSharer = SocialSharer()
    var cardSocialMessage: Observable<SocialMessage?> { return rxCardSocialMessage.asObservable() }
    var cardShowExactLocationOnMap: Observable<Bool> { return rxCardShowExactLocationOnMap.asObservable() }

    let rxCardProductInfo: Variable<ListingVMProductInfo?> = Variable<ListingVMProductInfo?>(nil)
    let rxCardProductStats: Variable<ListingStats?> =  Variable<ListingStats?>(nil)
    let rxCardSocialMessage: Variable<SocialMessage?> = Variable<SocialMessage?>(nil)
    let rxCardShowExactLocationOnMap: Variable<Bool> = Variable<Bool>(false)
}

private class MockListingCardDetailsView: ListingCardDetailsViewType {

    var isPopulateWithProductInfoCalled: Int = 0
    var isPopulateWithSocialSharerCalled: Int = 0
    var isPopulateWithSocialMessageCalled: Int = 0
    var isPopulateWithListingStatsCalled: Int = 0
    var showExactLocationOnMap: Bool = false

    func resetAllVariables() {
        isPopulateWithProductInfoCalled = 0
        isPopulateWithSocialSharerCalled = 0
        isPopulateWithSocialMessageCalled = 0
        isPopulateWithListingStatsCalled = 0
        showExactLocationOnMap = false
    }

    func populateWith(socialSharer: SocialSharer) {
        isPopulateWithSocialSharerCalled += 1
    }

    func populateWith(socialMessage: SocialMessage?) {
        isPopulateWithSocialMessageCalled += 1
    }
    
    func populateWith(productInfo: ListingVMProductInfo?, showExactLocationOnMap: Bool) {
        isPopulateWithProductInfoCalled += 1
        self.showExactLocationOnMap = showExactLocationOnMap
    }

    func populateWith(listingStats: ListingStats?, postedDate: Date?) {
        isPopulateWithListingStatsCalled += 1
    }
}
