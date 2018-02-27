//
//  SocialMessageSpec.swift
//  letgoTests
//
//  Created by Raúl de Oñate Blanco on 21/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class SocialMessageSpec: QuickSpec {
    
    override func spec() {
        
        var sut: SocialMessage!
        
        fdescribe("encode") {
            context("percentEncodeForAmpersands") {
                
                var telegramText: String!
                
                beforeEach {
                    sut = AppShareSocialMessage()
                    waitUntil { done in
                        sut.retrieveTelegramShareText(completion: { string in
                            telegramText = string
                            done()
                        })
                    }
                }
                it("is encoded correctly") {
                    expect(telegramText) == "letgo://product/0e56c1c5-fbfa-4a46-b226-e51fff967e1a?utm_campaign=product-detail-share%26utm_medium=whatsapp%26utm_source=ios_app"
                }
            }
        }
    }
    
}
