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
        var sut: LGDeepLinksRouter!
        let categoryID = String(ListingCategory.makeMock().rawValue)
        let queryString = String.makeRandom()
        let listingID = Listing.makeMock().objectId!

        beforeEach {
            sut = LGDeepLinksRouter()
        }

        describe("basic deferred deep linking") {

            context("targeting a specific category") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetCategory(categoryID) {
                        sut.onConversionDataReceived(installData)
                    }
                }

                it("sets the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink targeting that category with no query string") {
                    if let deeplink = sut.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: "", categories: categoryID)
                    }
                }

            }

            context("targeting a specific query search") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetQuery(queryString) {
                        sut.onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = sut.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: queryString, categories: nil)
                    }
                }
            }

            context("targeting a specific listing") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetListing(listingID) {
                        sut.onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = sut.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.listing(listingId: listingID)
                    }
                }
            }
        }

        describe("facebook deferred deep linking") {

            context("targeting a specific category") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeFacebookTargetCategory(categoryID) {
                        sut.onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = sut.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: "", categories: categoryID)
                    }
                }
            }

            context("targeting a specific query search") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetQuery(queryString) {
                        sut.onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = sut.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.search(query: queryString, categories: nil)
                    }
                }
            }

            context("targeting a specific listing") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeFacebookTargetListing(listingID) {
                        sut.onConversionDataReceived(installData)
                    }
                }
                it("sets the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beTrue())
                }
                it("sets a category search deeplink with a query string without category") {
                    if let deeplink = sut.consumeInitialDeepLink() {
                        expect(deeplink.action) == DeepLinkAction.listing(listingId: listingID)
                    }
                }
            }
        }

        describe("a failed deferred deep link arriving") {
            context("trying to parse the data") {
                beforeEach {
                    if let installData = MockDeferredDeepLinkMaker.makeTargetFail() {
                        sut.onConversionDataReceived(installData)
                    }
                }
                afterEach {
                    _ = sut.consumeInitialDeepLink()
                }
                it("does not set the initial deeplink properly") {
                    expect(sut.initialDeeplinkAvailable).to(beFalse())
                }
            }
        }
        
        describe("appShouldOpenInBrowser:url") {
            context("when checking jobs.letgo.com") {
                it("should return true") {
                    let url = URL(string: "http://jobs.letgo.com")!
                    expect(sut.appShouldOpenInBrowser(url: url)).to(beTrue())
                }
            }
            context("when checking we.letgo.com") {
                it("should return true") {
                    let url = URL(string: "http://we.letgo.com")!
                    expect(sut.appShouldOpenInBrowser(url: url)).to(beTrue())
                }
            }
            context("when checking a valid universal link") {
                it("should return false") {
                    let url = URL(string: "https://es.stg.letgo.com/es/i/")!
                    expect(sut.appShouldOpenInBrowser(url: url)).to(beFalse())
                }
            }
        }
        
        describe("AppsFlyer deeplink callback") {
            context("generated by iOS client") {
                beforeEach {
                    let attributionData = ["pid" : "af_app_invites",
                                           "af_dp" : "product/5abbd748-9ded-4922-8f7f-4c88aa9528ee?utm_campaign=product-detail-share&utm_medium=whatsapp&utm_source=ios_app",
                                           "af_referrer_custom_id" : "629127A2-ECEA-48C7-8DE3-83CC5C27D441",
                                           "ios_url" : "https://www.letgo.com/product/5abbd748-9ded-4922-8f7f-4c88aa9528ee",
                                           "link" : "https://letgo.onelink.me/O2PG/a3fc8168",
                                           "c" : "app-invite-friend",
                                           "af_channel" : "whatsapp",
                                           "$android_url" : "https://www.letgo.com/product/5abbd748-9ded-4922-8f7f-4c88aa9528ee",
                                           "af_siteid" : "986339882",
                                           "referrer_af_id" : "1518177145177-6644373",
                                           "fallback_url" : "https://www.letgo.com/product/5abbd748-9ded-4922-8f7f-4c88aa9528ee?utm_campaign=product-detail-share&utm_medium=whatsapp&utm_source=ios_app",
                                           "site_id" : "ios_app"]
                }
            }
        }
        
    }
}
