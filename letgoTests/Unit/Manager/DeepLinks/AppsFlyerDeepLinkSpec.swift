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
