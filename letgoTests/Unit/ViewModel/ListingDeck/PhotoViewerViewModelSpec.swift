//
//  PhotoViewerViewModelSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble

final class PhotoViewerViewModelSpec: QuickSpec {

    override func spec() {
        var sut: PhotoViewerViewModel!
        var urls: [URL] = []
        var listing: Listing!
        var listingViewModelMaker: MockListingViewModelMaker!
        var tracker: MockTracker!

        describe("A listing") {
            beforeEach {
                var productMock = MockProduct.makeMock()
                productMock.status = .approved
                listing = .product(productMock)
                tracker = MockTracker()

                listingViewModelMaker = MockListingViewModelMaker(myUserRepository: MockMyUserRepository(),
                                                                  userRepository: MockUserRepository(),
                                                                  listingRepository: MockListingRepository(),
                                                                  chatWrapper: MockChatWrapper(),
                                                                  locationManager: MockLocationManager(),
                                                                  countryHelper: CountryHelper.mock(),
                                                                  featureFlags: MockFeatureFlags(),
                                                                  purchasesShopper: MockPurchasesShopper(),
                                                                  monetizationRepository: MockMonetizationRepository(),
                                                                  tracker: MockTracker(),
                                                                  keyValueStorage: MockKeyValueStorage())
            }
            afterEach {
                urls.removeAll()
            }

            context("the viewmodel is set up") {
                beforeEach {
                    let source: EventParameterListingVisitSource = .listingList
                    let viewModel = listingViewModelMaker.make(listing: listing, visitSource: source)
                    let displayable = viewModel.makeDisplayable()
                    sut = PhotoViewerViewModel(imageDownloader: MockImageDownloader(),
                                               viewerDisplayable: displayable,
                                               tracker: tracker,
                                               source: source,
                                               featureFlags: MockFeatureFlags())
                }
                it("the photoviewer has no random image") {
                    expect(tracker.trackedEvents.count) == 0
                }
            }

            context("the viewmodel is set up and activated") {
                beforeEach {
                    let source: EventParameterListingVisitSource = .listingList
                    let viewModel = listingViewModelMaker.make(listing: listing, visitSource: source)
                    let displayable = viewModel.makeDisplayable()
                    sut = PhotoViewerViewModel(imageDownloader: MockImageDownloader(),
                                               viewerDisplayable: displayable,
                                               tracker: tracker,
                                               source: source,
                                               featureFlags: MockFeatureFlags())
                    sut.active = true
                }
                it("the photoviewer has no random image") {
                    expect(tracker.trackedEvents.count) == 1
                }
            }

            context("the viewmodel is set up and activated and the chat opens") {
                beforeEach {
                    let source: EventParameterListingVisitSource = .listingList
                    let viewModel = listingViewModelMaker.make(listing: listing, visitSource: source)
                    let displayable = viewModel.makeDisplayable()
                    sut = PhotoViewerViewModel(imageDownloader: MockImageDownloader(),
                                               viewerDisplayable: displayable,
                                               tracker: tracker,
                                               source: source,
                                               featureFlags: MockFeatureFlags())
                    sut.active = true
                    sut.didOpenChat()
                }
                it("the photoviewer has no random image") {
                    expect(tracker.trackedEvents.count) == 2
                }
            }

            context("the viewmodel is set up and the chat opens") {
                beforeEach {
                    let source: EventParameterListingVisitSource = .listingList
                    let viewModel = listingViewModelMaker.make(listing: listing, visitSource: source)
                    let displayable = viewModel.makeDisplayable()
                    sut = PhotoViewerViewModel(imageDownloader: MockImageDownloader(),
                                               viewerDisplayable: displayable,
                                               tracker: tracker,
                                               source: source,
                                               featureFlags: MockFeatureFlags())
                    sut.didOpenChat()
                }
                it("the photoviewer has no random image") {
                    expect(tracker.trackedEvents.count) == 0
                }
            }
        }
    }
}
