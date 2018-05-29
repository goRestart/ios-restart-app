@testable import LetGoGodMode
import Quick
import Nimble

class UriSchemeSpec: QuickSpec {
    override func spec() {
        var sut: UriScheme!
        var url: URL!
        var listingId: String!
        var message: String!
        var conversationId: String!
        
        describe("build from letgo scheme URL") {
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
                    listingId = String.makeRandom()
                    url = URL(string: "letgo://products_share/" + listingId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product share action") {
                    expect(sut.deepLink.action) == DeepLinkAction.listingShare(listingId: listingId)
                }
            }
            
            context("with a product mark as sold URL") {
                beforeEach {
                    listingId = String.makeRandom()
                    url = URL(string: "letgo://products_mark_as_sold/" + listingId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product mark as sold action") {
                    expect(sut.deepLink.action) == DeepLinkAction.listingMarkAsSold(listingId: listingId)
                }
            }
            
            context("with a product bump up URL") {
                beforeEach {
                    listingId = String.makeRandom()
                    url = URL(string: "letgo://products_bump_up/" + listingId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product bump up action") {
                    expect(sut.deepLink.action) == DeepLinkAction.listingBumpUp(listingId: listingId)
                }
            }
            
            context("with a product edit URL") {
                beforeEach {
                    listingId = String.makeRandom()
                    url = URL(string: "letgo://products_edit/" + listingId)
                    sut = UriScheme.buildFromUrl(url)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with product share action") {
                    expect(sut.deepLink.action) == DeepLinkAction.listingEdit(listingId: listingId)
                }
            }
            
            context("with a chat predefined message URL") {
                beforeEach {
                    url = URL(string: "letgo://chat/")
                    conversationId = String.makeRandom()
                    message = String.makeRandomPhrase(words: Int.makeRandom(), wordLengthMin: Int.makeRandom(min: 1, max: 5), wordLengthMax: Int.makeRandom(min: 5, max: 20))
                    let conversationQueryItem = URLQueryItem(name: "c", value: conversationId)
                    let messageQueryItem = URLQueryItem(name: "m", value: message)
                    var urlComponents = URLComponents(string: url.absoluteString)!
                    urlComponents.queryItems = [conversationQueryItem, messageQueryItem]
                    sut = UriScheme.buildFromUrl(urlComponents.url!)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with conversation with predefined message action") {
                    expect(sut.deepLink.action) == DeepLinkAction.conversationWithMessage(conversationId: conversationId, message: message)
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
            
            context("with a webview deeplink") {
                var url: URL!
                var linkString: String!
                var link: URL!
                beforeEach {
                    url = URL(string: "letgo://webview/")
                    linkString = "https://es.letgo.com/es/notifications?posting=true"
                    let linkQueryItem = URLQueryItem(name: "link", value: linkString)
                    var urlComponents = URLComponents(string: url.absoluteString)!
                    urlComponents.queryItems = [linkQueryItem]
                    sut = UriScheme.buildFromUrl(urlComponents.url!)
                }
                it("is not nil") {
                    expect(sut).toNot(beNil())
                }
                it("has a deep link with a webview action") {
                    link = URL(string: linkString)
                    expect(sut.deepLink.action) == DeepLinkAction.webView(url: link)
                }
            }
            
            describe("queryParameters getter from URL") {
                context("decode percent encoded URL") {
                    var decodedMessage: String!
                    beforeEach {
                        let url = URL(string:"letgo://chat/?c=conversation_id&m=hey%20bro%21%20%F0%9F%91%8B%F0%9F%8F%BC%20%20i%27m%20fine%2C%20and%20you%3F")!
                        let queryParameters = url.queryParameters
                        decodedMessage = queryParameters["m"]
                    }
                    it("correctly decodes any percent encoded URL") {
                        expect(decodedMessage) == "hey bro! 👋🏼  i'm fine, and you?"
                    }
                }
            }
        }
    }
}
