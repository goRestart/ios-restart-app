//
//  DeferredDeepLinksSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 28/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

class DeepLinksRouterSpec: QuickSpec {

    override func spec() {
        var deeplinksRouter: DeepLinksRouter!
        let categoryID = String(ListingCategory.makeMock().rawValue)
        let queryString = String.makeRandom()
        let listingID = Listing.makeMock().objectId!

        beforeEach {
            deeplinksRouter = LGDeepLinksRouter()
        }

        describe("basic deferred deep linking") {

            context("targeting a specific category") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetCategory(categoryID),
                        let onConversionDataReceived = deeplinksRouter.onConversionDataReceived {
                        onConversionDataReceived(installData)
                    }
                }

                it("sets the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink targeting that category with no query string") {
                    if let deeplink = deeplinksRouter.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: "", categories: categoryID)
                    }
                }

            }

            context("targeting a specific query search") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetQuery(queryString),
                        let onConversionDataReceived = deeplinksRouter.onConversionDataReceived {
                        onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = deeplinksRouter.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: queryString, categories: nil)
                    }
                }
            }

            context("targeting a specific listing") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetListing(listingID),
                        let onConversionDataReceived = deeplinksRouter.onConversionDataReceived {
                        onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = deeplinksRouter.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.listing(listingId: listingID)
                    }
                }
            }
        }

        describe("facebook deferred deep linking") {

            context("targeting a specific category") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeFacebookTargetCategory(categoryID),
                        let onConversionDataReceived = deeplinksRouter.onConversionDataReceived {
                        onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = deeplinksRouter.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: "", categories: categoryID)
                    }
                }
            }

            context("targeting a specific query search") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetQuery(queryString),
                        let onConversionDataReceived = deeplinksRouter.onConversionDataReceived {
                        onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = deeplinksRouter.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: queryString, categories: nil)
                    }
                }
            }

            context("targeting a specific listing") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeFacebookTargetListing(listingID),
                        let onConversionDataReceived = deeplinksRouter.onConversionDataReceived {
                        onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = deeplinksRouter.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.listing(listingId: listingID)
                    }
                }
            }
        }

        describe("a failed deferred deep link arriving") {
            context("trying to parse the data") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetFail(),
                        let makeTargetFail = deeplinksRouter.onConversionDataReceived {
                        makeTargetFail(installData)
                    }
                }
                afterEach {
                    _ = deeplinksRouter.consumeInitialDeepLink()
                }
                it("does not set the initial deeplink properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beFalse())
                }
            }
        }
        
    }
    
}
