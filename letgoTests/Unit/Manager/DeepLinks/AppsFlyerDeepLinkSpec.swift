//
//  AppsFlyerDeepLinkSpec.swift
//  letgoTests
//
//  Created by Raúl de Oñate Blanco on 21/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class AppsFlyerDeepLinkSpec: QuickSpec {
    
    override func spec() {
        fdescribe("AppsFlyerDeepLink") {
            describe("deeplink callback interpretation") {
                
                var deepLink: DeepLink!
                
                context("with path") {
                    beforeEach {
                        let attributionData = ["af_dp" : "product/5abbd748-9ded-4922-8f7f-4c88aa9528ee"]
                        deepLink = AppsFlyerDeepLink.buildFromAttributionData(attributionData)
                    }
                    it("path is parsed correctly") {
                        expect(deepLink.action).to(equal(DeepLinkAction.listing(listingId: "5abbd748-9ded-4922-8f7f-4c88aa9528ee")))
                    }
                }
                
                context("with path and query parameters") {
                    beforeEach {
                        let attributionData = ["af_dp" : "product/5abbd748-9ded-4922-8f7f-4c88aa9528ee?utm_campaign=product-detail-share&utm_medium=whatsapp&utm_source=ios_app"]
                        deepLink = AppsFlyerDeepLink.buildFromAttributionData(attributionData)
                    }
                    it("is parsed correctly") {
                        expect(deepLink.action).to(equal(DeepLinkAction.listing(listingId: "5abbd748-9ded-4922-8f7f-4c88aa9528ee")))
                    }
                    it("parses utm_medium correctly") {
                        expect(deepLink.medium).to(equal("whatsapp"))
                    }
                    it("parses utm_medium correctly") {
                        expect(deepLink.campaign).to(equal("product-detail-share"))
                    }
                    it("parses utm_medium correctly") {
                        expect(deepLink.source).to(equal(DeepLinkSource.external(source: "ios_app")))
                    }
                }

            }
        
            describe("percentEncodeForAmpersands") {
                context("correct encoding") {
                    var encodedString: String!
                    beforeEach {
                        let urlString = "letgo://product/0e56c1c5-fbfa-4a46-b226-e51fff967e1a?utm_campaign=product-detail-share&utm_medium=whatsapp&utm_source=ios_app"
                        encodedString = AppsFlyerDeepLink.percentEncodeForAmpersands(urlString: urlString)
                    }
                    it("is encoded correctly") {
                        expect(encodedString) == "letgo://product/0e56c1c5-fbfa-4a46-b226-e51fff967e1a?utm_campaign=product-detail-share%26utm_medium=whatsapp%26utm_source=ios_app"
                    }
                }
            }
        }
    }
    
}
