//
//  UriSchemeSpec.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 06/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class UriSchemeSpec: QuickSpec {
    override func spec() {
        var sut: UriScheme!
        var url: URL!
        var productId: String!
        var message: String!
        var conversationData: ConversationData!
        
        fdescribe("UriScheme") {
            describe("notification center") {
                context("notification center tab") {
                    beforeEach {
                        url = URL(string: "letgo://notification_center")
                        sut = UriScheme.buildFromUrl(url)
                    }
                    it("it is not nil and has the expected action") {
                        expect(sut.deepLink.action) == DeepLinkAction.notificationCenter
                    }
                }
            }
            
            describe("product detail") {
                beforeEach {
                    productId = String.makeRandom()
                }
                context("product share") {
                    beforeEach {
                        url = URL(string: "letgo://products_share/" + productId)
                        sut = UriScheme.buildFromUrl(url)
                    }
                    it("it is not nil and has the expected action") {
                        expect(sut.deepLink.action) == DeepLinkAction.productShare(productId: productId)
                    }
                }
                context("product mark as sold") {
                    beforeEach {
                        url = URL(string: "letgo://products_mark_as_sold/" + productId)
                        sut = UriScheme.buildFromUrl(url)
                    }
                    it("it is not nil and has the expected action") {
                        expect(sut.deepLink.action) == DeepLinkAction.productMarkAsSold(productId: productId)
                    }
                }
                context("product bump up") {
                    beforeEach {
                        url = URL(string: "letgo://products_bump_up/" + productId)
                        sut = UriScheme.buildFromUrl(url)
                    }
                    it("it is not nil and has the expected action") {
                        expect(sut.deepLink.action) == DeepLinkAction.productBumpUp(productId: productId)
                    }
                }
            }
            
            describe("chat detail") {
                context("chat detail with predefined message") {
                    beforeEach {
                        url = URL(string: "letgo://chat/")
                        let conversationId = String.makeRandom()
                        message = String.makeRandomPhrase(words: Int.makeRandom(), wordLengthMin: Int.makeRandom(min: 1, max: 5), wordLengthMax: Int.makeRandom(min: 5, max: 20))
                        let conversationQueryItem = URLQueryItem(name: "c", value: conversationId)
                        let messageQueryItem = URLQueryItem(name: "m", value: message)
                        var urlComponents = URLComponents(string: url.absoluteString)!
                        urlComponents.queryItems = [conversationQueryItem, messageQueryItem]
                        sut = UriScheme.buildFromUrl(urlComponents.url!)
                        
                        conversationData = ConversationData.conversation(conversationId: conversationId)
                    }
                    it("it is not nil and has the expected action") {
                        expect(sut.deepLink.action) == DeepLinkAction.conversationWithMessage(data: conversationData, message: message)
                    }
                }
            }
        }
    }
}
