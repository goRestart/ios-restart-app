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
        
        describe("build from URL") {
            context("with a notification center URL") {
                beforeEach {
                    url = URL(string: "letgo://notification_center")
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with notification center action") {
                    expect(sut.deepLink.action) == DeepLinkAction.notificationCenter
                }
            }
            
            context("with a product share URL") {
                beforeEach {
                    productId = String.makeRandom()
                    url = URL(string: "letgo://products_share/" + productId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product share action") {
                    expect(sut.deepLink.action) == DeepLinkAction.productShare(productId: productId)
                }
            }
            
            context("with a product mark as sold URL") {
                beforeEach {
                    productId = String.makeRandom()
                    url = URL(string: "letgo://products_mark_as_sold/" + productId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product mark as sold action") {
                    expect(sut.deepLink.action) == DeepLinkAction.productMarkAsSold(productId: productId)
                }
            }
            
            context("with a product bump up URL") {
                beforeEach {
                    productId = String.makeRandom()
                    url = URL(string: "letgo://products_bump_up/" + productId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product bump up action") {
                    expect(sut.deepLink.action) == DeepLinkAction.productBumpUp(productId: productId)
                }
            }
            
            context("with a chat predefined message URL") {
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
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with conversation with predefined message action") {
                    expect(sut.deepLink.action) == DeepLinkAction.conversationWithMessage(data: conversationData, message: message)
                }
            }
            
            context("with an App Store URL") {
                beforeEach {
                    url = URL(string: "letgo://update_app")
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with an app store action") {
                    expect(sut.deepLink.action) == DeepLinkAction.appStore
                }
            }
        }
    }
}
