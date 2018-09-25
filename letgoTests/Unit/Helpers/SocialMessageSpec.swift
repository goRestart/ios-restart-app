@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class SocialMessageSpec: QuickSpec {
    
    override func spec() {

        describe("ListingSocialMessage") {
            var sut: ListingSocialMessage!
            var listing: Listing!
            var user: MyUser!

            describe("utm params url") {
                context("default campaign")  {
                    let productMock = MockProduct.makeMock()
                    listing = .product(productMock)
                    user = MockMyUser.makeMock()
                    let url = "product/\(listing.objectId!)"

                    beforeEach {
                        sut = ListingSocialMessage(listing: listing,
                                                   fallbackToStore: false,
                                                   myUserId: user.objectId,
                                                   myUserName: user.name)
                    }

                    it("utm_campaign is product-detail-share") {
                        expect(sut.addUtmParamsToURLString(url, source: .facebook)) == "\(url)?utm_campaign=product-detail-share%26utm_medium=facebook%26utm_source=ios_app"
                    }
                }

                context("detail campaign")  {
                    listing = .product(MockProduct.makeMock())
                    user = MockMyUser.makeMock()
                    let url = "product/\(listing.objectId!)"

                    beforeEach {
                        sut = ListingSocialMessage(listing: listing,
                                                   fallbackToStore: false,
                                                   myUserId: user.objectId,
                                                   myUserName: user.name,
                                                   campaign: .detail)
                    }

                    it("utm_campaign is product-detail-share") {
                        expect(sut.addUtmParamsToURLString(url, source: .facebook)) == "\(url)?utm_campaign=product-detail-share%26utm_medium=facebook%26utm_source=ios_app"
                    }
                }

                context("posted campaign")  {
                    let productMock = MockProduct.makeMock()
                    listing = .product(productMock)
                    user = MockMyUser.makeMock()
                    let url = "product/\(listing.objectId!)"

                    beforeEach {
                        sut = ListingSocialMessage(listing: listing,
                                                   fallbackToStore: false,
                                                   myUserId: user.objectId,
                                                   myUserName: user.name,
                                                   campaign: .posted)
                    }

                    it("utm_campaign is product-sell-confirmation-share") {
                        expect(sut.addUtmParamsToURLString(url, source: .facebook)) == "\(url)?utm_campaign=product-sell-confirmation-share%26utm_medium=facebook%26utm_source=ios_app"
                    }
                }
            }
        }
    }
}
