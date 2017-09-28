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

        let deeplinksRouter = LGDeepLinksRouter.sharedInstance

        describe("We build the deeplink for") {

            afterEach {
                _ = deeplinksRouter.consumeInitialDeepLink()
            }

            context("targeting a specific category") {
                beforeEach {
                    let installData = MockDeferredDeepLinkMaker.makeTargetCategory()
                    deeplinksRouter.onConversionDataReceived(installData)
                }
                it("and check if initial deeplink is set properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }

            }

            context("targeting a specific query search") {
                beforeEach {
                    let installData = MockDeferredDeepLinkMaker.makeTargetQuery()
                    deeplinksRouter.onConversionDataReceived(installData)
                }
                it("and check if initial deeplink is set properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
            }

            context("targeting a specific listing") {
                beforeEach {
                    let installData = MockDeferredDeepLinkMaker.makeTargetListing()
                    deeplinksRouter.onConversionDataReceived(installData)
                }
                it("and check if initial deeplink is set properly") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beTrue())
                }
            }
        }

        describe("If an installation data is empty or corrupted") {
            context("When trying to build the final deeplink") {
                beforeEach {
                    let installData = MockDeferredDeepLinkMaker.makeTargetFail()
                    deeplinksRouter.onConversionDataReceived(installData)
                }
                it("the initial deeplink is not set") {
                    expect(deeplinksRouter.initialDeeplinkAvailable).to(beFalse())
                }
            }
        }
        
    }
    
}
