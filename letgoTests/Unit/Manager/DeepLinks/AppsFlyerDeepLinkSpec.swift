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
        describe("AppsFlyerDeepLink") {
            describe("deeplink callback interpretation") {
                
                var deepLink: DeepLink!
                
                context("with path") {
                    beforeEach {
                        let attributionData = [AppsFlyerDeepLink.afdpParam : "product/5abbd748-9ded-4922-8f7f-4c88aa9528ee"]
                        deepLink = AppsFlyerDeepLink.buildFromAttributionData(attributionData)
                    }
                    it("action is parsed correctly") {
                        expect(deepLink.action).to(equal(DeepLinkAction.listing(listingId: "5abbd748-9ded-4922-8f7f-4c88aa9528ee")))
                    }
                }
                
                context("with path and query parameters") {
                    beforeEach {
                        let attributionData = [AppsFlyerDeepLink.afdpParam : "product/5abbd748-9ded-4922-8f7f-4c88aa9528ee?utm_campaign=product-detail-share&utm_medium=whatsapp&utm_source=ios_app"]
                        deepLink = AppsFlyerDeepLink.buildFromAttributionData(attributionData)
                    }
                    it("action is parsed correctly") {
                        expect(deepLink.action).to(equal(DeepLinkAction.listing(listingId: "5abbd748-9ded-4922-8f7f-4c88aa9528ee")))
                    }
                    it("parses utm_medium correctly") {
                        expect(deepLink.medium).to(equal("whatsapp"))
                    }
                    it("parses utm_campaign correctly") {
                        expect(deepLink.campaign).to(equal("product-detail-share"))
                    }
                    it("parses utm_source correctly") {
                        expect(deepLink.source).to(equal(DeepLinkSource.external(source: "ios_app")))
                    }
                }

            }
            
            describe("buildFromUrl") {
                
                var url: URL!
                var appsFlyerDeepLink: AppsFlyerDeepLink!
                
                context("long url") {
                    beforeEach {
                        url = URL(string: "https://letgo.onelink.me/O2PG?pid=organic_email&c=search_alert&af_dp=letgo%3A%2F%2Fsearch%3Fquery%3Dleptop%26utm_source%3Demail%26utm_medium%3Dtransactional%26utm_campaign%3Dsearch_alert&af_web_dp=https%3A%2F%2Fwww.letgo.com%2Fsearch%2Fleptop%3Futm_source%3Demail%26utm_medium%3Dtransactional%26utm_campaign%3Dsearch_alert")
                        appsFlyerDeepLink = AppsFlyerDeepLink.buildFromUrl(url)
                    }
                    it("action is parsed correctly") {
                        expect(appsFlyerDeepLink.deepLink.action).to(equal(DeepLinkAction.search(query: "leptop",
                                                                                                 categories: nil,
                                                                                                 distanceRadius: nil,
                                                                                                 sortCriteria: nil,
                                                                                                 priceFlag: nil,
                                                                                                 minPrice: nil,
                                                                                                 maxPrice: nil)))
                    }
                    it("parses utm_medium correctly") {
                        expect(appsFlyerDeepLink.deepLink.medium).to(equal("transactional"))
                    }
                    it("parses campaign correctly") {
                        expect(appsFlyerDeepLink.deepLink.campaign).to(equal("search_alert"))
                    }
                    it("parses utm_source correctly") {
                        expect(appsFlyerDeepLink.deepLink.source).to(equal(DeepLinkSource.external(source: "email")))
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
