import LetGo
import LGCoreKit
import Quick
import Nimble

class TrackerEventSpec: QuickSpec {
    override func spec() {
        var sut: TrackerEvent!
        
        describe("factory methods") {
            describe("loginVisit") {
                it("has its event name") {
                    sut = TrackerEvent.loginVisit(.Sell)
                    expect(sut.name.rawValue).to(equal("login-screen"))
                }
                it("contains the appropiate login source when visiting login from posting") {
                    sut = TrackerEvent.loginVisit(.Sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source when visiting login from chats") {
                    sut = TrackerEvent.loginVisit(.Chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source when visiting login from profile") {
                    sut = TrackerEvent.loginVisit(.Profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source when visiting login from mark as favourite") {
                    sut = TrackerEvent.loginVisit(.Favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source when visiting login from make an offer") {
                    sut = TrackerEvent.loginVisit(.MakeOffer)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source when visiting login from mark as sold") {
                    sut = TrackerEvent.loginVisit(.MarkAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source when visiting login from as a question") {
                    sut = TrackerEvent.loginVisit(.AskQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source when visiting login from report fraud") {
                    sut = TrackerEvent.loginVisit(.ReportFraud)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }
            
            describe("loginAbandon") {
                it("has its event name") {
                    sut = TrackerEvent.loginAbandon(.Sell)
                    expect(sut.name.rawValue).to(equal("login-abandon"))
                }
                it("contains the appropiate login source when abandoning login from posting") {
                    sut = TrackerEvent.loginAbandon(.Sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source when abandoning login from chats") {
                    sut = TrackerEvent.loginAbandon(.Chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source when abandoning login from profile") {
                    sut = TrackerEvent.loginAbandon(.Profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source when abandoning login from mark as favourite") {
                    sut = TrackerEvent.loginAbandon(.Favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source when abandoning login from make an offer") {
                    sut = TrackerEvent.loginAbandon(.MakeOffer)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source when abandoning login from mark as sold") {
                    sut = TrackerEvent.loginAbandon(.MarkAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source when abandoning login from as a question") {
                    sut = TrackerEvent.loginAbandon(.AskQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source when abandoning login from report fraud") {
                    sut = TrackerEvent.loginAbandon(.ReportFraud)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }

            describe("loginFB") {
                it("has its event name") {
                    sut = TrackerEvent.loginFB(.Sell)
                    expect(sut.name.rawValue).to(equal("login-fb"))
                }
                it("contains the appropiate login source logging in via FB from posting") {
                    sut = TrackerEvent.loginFB(.Sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source logging in via FB from chats") {
                    sut = TrackerEvent.loginFB(.Chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source logging in via FB from profile") {
                    sut = TrackerEvent.loginFB(.Profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source logging in via FB from mark as favourite") {
                    sut = TrackerEvent.loginFB(.Favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source logging in via FB from make an offer") {
                    sut = TrackerEvent.loginFB(.MakeOffer)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source logging in via FB from mark as sold") {
                    sut = TrackerEvent.loginFB(.MarkAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source logging in via FB from as a question") {
                    sut = TrackerEvent.loginFB(.AskQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source logging in via FB from report fraud") {
                    sut = TrackerEvent.loginFB(.ReportFraud)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }

            describe("loginEmail") {
                it("has its event name") {
                    sut = TrackerEvent.loginEmail(.Sell)
                    expect(sut.name.rawValue).to(equal("login-email"))
                }
                it("contains the appropiate login source logging in via email from posting") {
                    sut = TrackerEvent.loginEmail(.Sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source logging in via email from chats") {
                    sut = TrackerEvent.loginEmail(.Chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source logging in via email from profile") {
                    sut = TrackerEvent.loginEmail(.Profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source logging in via email from mark as favourite") {
                    sut = TrackerEvent.loginEmail(.Favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source logging in via email from make an offer") {
                    sut = TrackerEvent.loginEmail(.MakeOffer)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source logging in via email from mark as sold") {
                    sut = TrackerEvent.loginEmail(.MarkAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source logging in via email from as a question") {
                    sut = TrackerEvent.loginEmail(.AskQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source logging in via email from report fraud") {
                    sut = TrackerEvent.loginEmail(.ReportFraud)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }
            
            describe("signupEmail") {
                it("has its event name") {
                    sut = TrackerEvent.signupEmail(.Sell, email: "test@test.com")
                    expect(sut.name.rawValue).to(equal("signup-email"))
                }
                it("contains the appropiate login source signing in via email from posting") {
                    sut = TrackerEvent.signupEmail(.Sell, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source signing in via email from chats") {
                    sut = TrackerEvent.signupEmail(.Chats, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source signing in via email from profile") {
                    sut = TrackerEvent.signupEmail(.Profile, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source signing in via email from mark as favourite") {
                    sut = TrackerEvent.signupEmail(.Favourite, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source signing in via email from make an offer") {
                    sut = TrackerEvent.signupEmail(.MakeOffer, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source signing in via email from mark as sold") {
                    sut = TrackerEvent.signupEmail(.MarkAsSold, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source signing in via email from as a question") {
                    sut = TrackerEvent.signupEmail(.AskQuestion, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source signing in via email from report fraud") {
                    sut = TrackerEvent.signupEmail(.ReportFraud, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
                it("contains the passed by email") {
                    sut = TrackerEvent.signupEmail(.ReportFraud, email: "test@test.com")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-email"]).notTo(beNil())
                    let userEmail = sut.params!.stringKeyParams["user-email"] as? String
                    expect(userEmail).to(equal("test@test.com"))
                }
            }
            
            describe("resetPassword") {
                it("has its event name") {
                    sut = TrackerEvent.resetPassword(.Sell)
                    expect(sut.name.rawValue).to(equal("login-reset-password"))
                }
                it("contains the appropiate login source resetting pwd from posting") {
                    sut = TrackerEvent.resetPassword(.Sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source resetting pwd from chats") {
                    sut = TrackerEvent.resetPassword(.Chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source resetting pwd from profile") {
                    sut = TrackerEvent.resetPassword(.Profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source resetting pwd from mark as favourite") {
                    sut = TrackerEvent.resetPassword(.Favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source resetting pwd from make an offer") {
                    sut = TrackerEvent.resetPassword(.MakeOffer)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source resetting pwd from mark as sold") {
                    sut = TrackerEvent.resetPassword(.MarkAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source resetting pwd from as a question") {
                    sut = TrackerEvent.resetPassword(.AskQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source resetting pwd from report fraud") {
                    sut = TrackerEvent.resetPassword(.ReportFraud)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }
            
            describe("logout") {
                it("has its event name") {
                    sut = TrackerEvent.logout()
                    expect(sut.name.rawValue).to(equal("logout"))
                }
            }
            
            describe("productList") {
                it("has its event name") {
                    sut = TrackerEvent.productList(nil, categories: nil, searchQuery: nil, pageNumber: 0)
                    expect(sut.name.rawValue).to(equal("product-list"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productList(user, categories: nil, searchQuery: nil, pageNumber: 0)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the category related params when passing by a category") {
                    let categories: [ProductCategory] = [.HomeAndGarden]
                    sut = TrackerEvent.productList(nil, categories: categories, searchQuery: nil, pageNumber: 0)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("4"))
                }
                it("contains the category related params when passing by several categories") {
                    let categories: [ProductCategory] = [.HomeAndGarden, .FashionAndAccesories]
                    sut = TrackerEvent.productList(nil, categories: categories, searchQuery: nil, pageNumber: 0)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("4,6"))
                }
                it("contains the search query related params when passing by a search query") {
                    let searchQuery = "iPhone"
                    sut = TrackerEvent.productList(nil, categories: nil, searchQuery: searchQuery, pageNumber: 0)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["search-keyword"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["search-keyword"] as? String
                    expect(categoryId).to(equal(searchQuery))
                }
                it("contains the page number related params when passing by the page number") {
                    sut = TrackerEvent.productList(nil, categories: nil, searchQuery: nil, pageNumber: 22)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["page-number"]).notTo(beNil())
                    let pageNumber = sut.params!.stringKeyParams["page-number"] as? Int
                    expect(pageNumber).to(equal(22))
                }
            }

            describe("searchStart") {
                it("has its event name") {
                    sut = TrackerEvent.searchStart(nil)
                    expect(sut.name.rawValue).to(equal("search-start"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.searchStart(user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
            }
            
            describe("searchComplete") {
                it("has its event name") {
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "")
                    expect(sut.name.rawValue).to(equal("search-complete"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.searchComplete(user, searchQuery: "")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the search keyword related params when passing by the search query") {
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone")
                    
                    expect(sut.params!.stringKeyParams["search-keyword"]).notTo(beNil())
                    let searchQuery = sut.params!.stringKeyParams["search-keyword"] as? String
                    expect(searchQuery).to(equal("iPhone"))
                }
            }

            describe("productDetailVisit") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDetailVisit(product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-detail-visit"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress.countryCode = "ES"
                    myUser.postalAddress.zipCode = "08026"
                    myUser.postalAddress.city = "Barcelona"
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress.countryCode = "NL"
                    productUser.postalAddress.zipCode = "GD 1013"
                    productUser.postalAddress.city = "Amsterdam"
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = NSNumber(double: 123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.categoryId = NSNumber(integer: 4)
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress.countryCode = "US"
                    product.postalAddress.zipCode = "12345"
                    product.postalAddress.city = "Baltimore"
                    
                    sut = TrackerEvent.productDetailVisit(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(product.name))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                    expect(sut.params!.stringKeyParams["product-country"]).notTo(beNil())
                    let productCountry = sut.params!.stringKeyParams["product-country"] as? String
                    expect(productCountry).to(equal(product.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["product-zipcode"]).notTo(beNil())
                    let productZipCode = sut.params!.stringKeyParams["product-zipcode"] as? String
                    expect(productZipCode).to(equal(product.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["product-city"]).notTo(beNil())
                    let productCity = sut.params!.stringKeyParams["product-city"] as? String
                    expect(productCity).to(equal(product.postalAddress.city))
                    
                    expect(sut.params!.stringKeyParams["product-lat"]).notTo(beNil())
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(product.location!.latitude))
                    
                    expect(sut.params!.stringKeyParams["product-lng"]).notTo(beNil())
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(product.location!.longitude))
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user!.objectId))

                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("real"))
                    
                    // My user
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let myUserId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(myUserId).to(equal(myUser.objectId))
                }
            }
            
            describe("productOffer") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productOffer(product, user: nil, amount: 0)
                    expect(sut.name.rawValue).to(equal("product-detail-offer"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress.countryCode = "ES"
                    myUser.postalAddress.zipCode = "08026"
                    myUser.postalAddress.city = "Barcelona"
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress.countryCode = "NL"
                    productUser.postalAddress.zipCode = "GD 1013"
                    productUser.postalAddress.city = "Amsterdam"
                    productUser.isDummy = true
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = NSNumber(double: 123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.categoryId = NSNumber(integer: 4)
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress.countryCode = "US"
                    product.postalAddress.zipCode = "12345"
                    product.postalAddress.city = "Baltimore"
                    
                    sut = TrackerEvent.productOffer(product, user: myUser, amount: 0)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(product.name))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                    expect(sut.params!.stringKeyParams["product-country"]).notTo(beNil())
                    let productCountry = sut.params!.stringKeyParams["product-country"] as? String
                    expect(productCountry).to(equal(product.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["product-zipcode"]).notTo(beNil())
                    let productZipCode = sut.params!.stringKeyParams["product-zipcode"] as? String
                    expect(productZipCode).to(equal(product.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["product-city"]).notTo(beNil())
                    let productCity = sut.params!.stringKeyParams["product-city"] as? String
                    expect(productCity).to(equal(product.postalAddress.city))
                    
                    expect(sut.params!.stringKeyParams["product-lat"]).notTo(beNil())
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(product.location!.latitude))
                    
                    expect(sut.params!.stringKeyParams["product-lng"]).notTo(beNil())
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(product.location!.longitude))
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user!.objectId))
                    
                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("dummy"))
                    
                    // My user
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let myUserId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(myUserId).to(equal(myUser.objectId))
                }
                it("contains the offered amount when passing it by") {
                    let product = MockProduct()
                    sut = TrackerEvent.productOffer(product, user: nil, amount: 25.67)
                    
                    expect(sut.params!.stringKeyParams["amount-offer"]).notTo(beNil())
                    let amount = sut.params!.stringKeyParams["amount-offer"] as? Double
                    expect(amount).to(equal(25.67))
                }
            }

            describe("productAskQuestion") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productAskQuestion(product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-detail-ask-question"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress.countryCode = "ES"
                    myUser.postalAddress.zipCode = "08026"
                    myUser.postalAddress.city = "Barcelona"
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress.countryCode = "NL"
                    productUser.postalAddress.zipCode = "GD 1013"
                    productUser.postalAddress.city = "Amsterdam"
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = NSNumber(double: 123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.categoryId = NSNumber(integer: 4)
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress.countryCode = "US"
                    product.postalAddress.zipCode = "12345"
                    product.postalAddress.city = "Baltimore"
                    
                    sut = TrackerEvent.productAskQuestion(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(product.name))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                    expect(sut.params!.stringKeyParams["product-country"]).notTo(beNil())
                    let productCountry = sut.params!.stringKeyParams["product-country"] as? String
                    expect(productCountry).to(equal(product.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["product-zipcode"]).notTo(beNil())
                    let productZipCode = sut.params!.stringKeyParams["product-zipcode"] as? String
                    expect(productZipCode).to(equal(product.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["product-city"]).notTo(beNil())
                    let productCity = sut.params!.stringKeyParams["product-city"] as? String
                    expect(productCity).to(equal(product.postalAddress.city))
                    
                    expect(sut.params!.stringKeyParams["product-lat"]).notTo(beNil())
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(product.location!.latitude))
                    
                    expect(sut.params!.stringKeyParams["product-lng"]).notTo(beNil())
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(product.location!.longitude))
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user!.objectId))
                    
                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("real"))
                    
                    // My user
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let myUserId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(myUserId).to(equal(myUser.objectId))
                }
            }
            
            describe("productMarkAsSold") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-detail-sold"))
                }
                it("contains the appropiate mark as sold source when starting the action from mark as sold") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product, user: nil)
                    
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["type-page"] as? String
                    expect(loginType).to(equal("product-detail"))
                }
                it("contains the appropiate mark as sold source when starting the action from delete") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsSold(.Delete, product: product, user: nil)

                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["type-page"] as? String
                    expect(loginType).to(equal("product-delete"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress.countryCode = "ES"
                    myUser.postalAddress.zipCode = "08026"
                    myUser.postalAddress.city = "Barcelona"
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = NSNumber(double: 123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.categoryId = NSNumber(integer: 4)
                    product.user = myUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress.countryCode = "US"
                    product.postalAddress.zipCode = "12345"
                    product.postalAddress.city = "Baltimore"
                    
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(product.name))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                    expect(sut.params!.stringKeyParams["product-country"]).notTo(beNil())
                    let productCountry = sut.params!.stringKeyParams["product-country"] as? String
                    expect(productCountry).to(equal(product.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["product-zipcode"]).notTo(beNil())
                    let productZipCode = sut.params!.stringKeyParams["product-zipcode"] as? String
                    expect(productZipCode).to(equal(product.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["product-city"]).notTo(beNil())
                    let productCity = sut.params!.stringKeyParams["product-city"] as? String
                    expect(productCity).to(equal(product.postalAddress.city))
                    
                    expect(sut.params!.stringKeyParams["product-lat"]).notTo(beNil())
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(product.location!.latitude))
                    
                    expect(sut.params!.stringKeyParams["product-lng"]).notTo(beNil())
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(product.location!.longitude))
                    
                    // Does not include user-to-id
                    expect(sut.params!.stringKeyParams["user-to-id"]).to(beNil())
                    
                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("real"))
                    
                    // My user
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let myUserId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(myUserId).to(equal(myUser.objectId))
                }
            }

            describe("productSellStart") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellStart(user)
                    expect(sut.name.rawValue).to(equal("product-sell-start"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellStart(user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
            }
            
            describe("productSellAddPicture") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellAddPicture(user, imageCount: 3)
                    expect(sut.name.rawValue).to(equal("product-sell-add-picture"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellAddPicture(user, imageCount: 3)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains picture number when passing it by") {
                    sut = TrackerEvent.productSellAddPicture(nil, imageCount: 3)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["number"]).notTo(beNil())
                    let pageNumber = sut.params!.stringKeyParams["number"] as? Int
                    expect(pageNumber).to(equal(3))
                }
            }

            describe("productSellEditTitle") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellEditTitle(user)
                    expect(sut.name.rawValue).to(equal("product-sell-edit-title"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellEditTitle(user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
            }

            describe("productSellEditPrice") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellEditPrice(user)
                    expect(sut.name.rawValue).to(equal("product-sell-edit-price"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellEditPrice(user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
            }
            
            describe("productSellEditDescription") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellEditDescription(user)
                    expect(sut.name.rawValue).to(equal("product-sell-edit-description"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellEditDescription(user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
            }
            
            describe("productSellEditCategory") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellEditCategory(user, category: nil)
                    expect(sut.name.rawValue).to(equal("product-sell-edit-category"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellEditCategory(user, category: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the category related params when passing by a nil category") {
                    sut = TrackerEvent.productSellEditCategory(nil, category: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(0))
                }
                it("contains the category related params when passing by a category") {
                    sut = TrackerEvent.productSellEditCategory(nil, category: .HomeAndGarden)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(4))
                }
            }
            
            describe("productSellEditShareFB") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellEditShareFB(nil, enabled: true)
                    expect(sut.name.rawValue).to(equal("product-edit-edit-share-fb"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellEditShareFB(user, enabled: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the switch enabled related params when passing it by") {
                    sut = TrackerEvent.productSellEditShareFB(nil, enabled: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["enabled"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["enabled"] as? Bool
                    expect(categoryId).to(equal(true))
                }
            }
            
            describe("productSellFormValidationFailed") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellFormValidationFailed(nil, description: "whatever")
                    expect(sut.name.rawValue).to(equal("product-sell-form-validation-failed"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellFormValidationFailed(user, description: "whatever")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the description related params") {
                    sut = TrackerEvent.productSellFormValidationFailed(nil, description: "whatever")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["description"] as? String
                    expect(description).to(equal("whatever"))
                }
            }

            describe("productSellSharedFB") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productSellSharedFB(nil, product: product)
                    expect(sut.name.rawValue).to(equal("product-sell-shared-fb"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productSellSharedFB(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product related params when passing by a product") {
                    let product = MockProduct()
                    product.name = "Bocata de paté"
                    
                    sut = TrackerEvent.productSellSharedFB(nil, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(product.name))
                }
            }

            describe("productSellAbandon") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellAbandon(user)
                    expect(sut.name.rawValue).to(equal("product-sell-abandon"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    
                    sut = TrackerEvent.productSellAbandon(user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
            }

            describe("productSellComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productSellComplete(nil, product: product)
                    expect(sut.name.rawValue).to(equal("product-sell-complete"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productSellComplete(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product related params when passing by a product") {
                    let product = MockProduct()
                    product.name = "bruce lee poster"
                    product.categoryId = NSNumber(integer: 4)
                    
                    sut = TrackerEvent.productSellComplete(nil, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(4))
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(product.name))
                }
            }
            
            describe("productEditStart") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditStart(user, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-start"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditStart(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditStart(nil, product: product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditAddPicture") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditAddPicture(user, product: product, imageCount: 3)
                    expect(sut.name.rawValue).to(equal("product-edit-add-picture"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditAddPicture(user, product: product, imageCount: 3)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains picture number when passing it by") {
                    let product = MockProduct()
                    sut = TrackerEvent.productEditAddPicture(nil, product: product, imageCount: 3)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["number"]).notTo(beNil())
                    let pageNumber = sut.params!.stringKeyParams["number"] as? Int
                    expect(pageNumber).to(equal(3))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditAddPicture(nil, product: product, imageCount: 3)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditEditTitle") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditEditTitle(user, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-edit-title"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditEditTitle(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditEditTitle(nil, product: product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditEditPrice") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditEditPrice(user, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-edit-price"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditEditPrice(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditEditPrice(nil, product: product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditEditDescription") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditEditDescription(user, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-edit-description"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditEditDescription(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditEditDescription(nil, product: product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditEditCategory") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditEditCategory(user, product: product, category: nil)
                    expect(sut.name.rawValue).to(equal("product-edit-edit-category"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditEditCategory(user, product: product, category: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the category related params when passing by a nil category") {
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productEditEditCategory(nil, product: product, category: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(0))
                }
                it("contains the category related params when passing by a category") {
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productEditEditCategory(nil, product: product, category: .HomeAndGarden)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(4))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditEditCategory(nil, product: product, category: nil)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditEditShareFB") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditEditShareFB(nil, product: product, enabled: true)
                    expect(sut.name.rawValue).to(equal("product-edit-edit-share-fb"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditEditShareFB(user, product: product, enabled: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the switch enabled related params when passing it by") {
                    let product = MockProduct()
                    sut = TrackerEvent.productEditEditShareFB(nil, product: product, enabled: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["enabled"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["enabled"] as? Bool
                    expect(categoryId).to(equal(true))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditEditShareFB(nil, product: product, enabled: true)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditFormValidationFailed") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditFormValidationFailed(nil, product: product, description: "whatever")
                    expect(sut.name.rawValue).to(equal("product-edit-form-validation-failed"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    product.objectId = "qwerty"
                    
                    sut = TrackerEvent.productEditFormValidationFailed(user, product: product, description: "whatever")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the description related params") {
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productEditFormValidationFailed(nil, product: product, description: "whatever")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["description"] as? String
                    expect(description).to(equal("whatever"))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditFormValidationFailed(nil, product: product, description: "whatever")
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditSharedFB") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productEditSharedFB(nil, product: product, name: "name")
                    expect(sut.name.rawValue).to(equal("product-edit-shared-fb"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productEditSharedFB(user, product: product, name: "name")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product related params when passing by a product") {
                    let product = MockProduct()
                    let newName = "Bocata de paté"
                    
                    sut = TrackerEvent.productEditSharedFB(nil, product: product, name: newName)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(newName))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditSharedFB(nil, product: product, name: "name")
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditAbandon") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditAbandon(user, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-abandon"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productEditAbandon(user, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditAbandon(nil, product: product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productEditComplete(nil, product: product, name: "name", category: nil)
                    expect(sut.name.rawValue).to(equal("product-edit-complete"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productEditComplete(user, product: product, name: "name", category: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product related params when passing by a product, name & category") {
                    let product = MockProduct()
                    let newName = "bruce lee poster"
                    let newCategory = ProductCategory.CarsAndMotors
                    
                    sut = TrackerEvent.productEditComplete(nil, product: product, name: newName, category: newCategory)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(newCategory.rawValue))
                    
                    expect(sut.params!.stringKeyParams["product-name"]).notTo(beNil())
                    let productName = sut.params!.stringKeyParams["product-name"] as? String
                    expect(productName).to(equal(newName))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditComplete(nil, product: product, name: "name", category: nil)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productDeleteStart") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDeleteStart(product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-delete-start"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productDeleteStart(product, user: user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productDeleteStart(product, user: nil)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productDeleteAbandon") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDeleteAbandon(product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-delete-abandon"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productDeleteAbandon(product, user: user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productDeleteAbandon(product, user: nil)

                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productDeleteComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDeleteComplete(product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-delete-complete"))
                }
                it("contains the user related params when passing by a user") {
                    let user = MockUser()
                    user.objectId = "12345"
                    user.postalAddress.countryCode = "ES"
                    user.postalAddress.zipCode = "08026"
                    user.postalAddress.city = "Barcelona"
                    let product = MockProduct()
                    
                    sut = TrackerEvent.productDeleteComplete(product, user: user)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let userId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(userId).to(equal(user.objectId))
                    
                    expect(sut.params!.stringKeyParams["user-country"]).notTo(beNil())
                    let userCountry = sut.params!.stringKeyParams["user-country"] as? String
                    expect(userCountry).to(equal(user.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["user-zipcode"]).notTo(beNil())
                    let userZipCode = sut.params!.stringKeyParams["user-zipcode"] as? String
                    expect(userZipCode).to(equal(user.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["user-city"]).notTo(beNil())
                    let userCity = sut.params!.stringKeyParams["user-city"] as? String
                    expect(userCity).to(equal(user.postalAddress.city))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productDeleteComplete(product, user: nil)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("userMessageSent") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.userMessageSent(product, user: nil)
                    expect(sut.name.rawValue).to(equal("user-sent-message"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress.countryCode = "ES"
                    myUser.postalAddress.zipCode = "08026"
                    myUser.postalAddress.city = "Barcelona"
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress.countryCode = "NL"
                    productUser.postalAddress.zipCode = "GD 1013"
                    productUser.postalAddress.city = "Amsterdam"
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = NSNumber(double: 123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.categoryId = NSNumber(integer: 4)
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress.countryCode = "US"
                    product.postalAddress.zipCode = "12345"
                    product.postalAddress.city = "Baltimore"
                    
                    sut = TrackerEvent.userMessageSent(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                    expect(sut.params!.stringKeyParams["product-country"]).notTo(beNil())
                    let productCountry = sut.params!.stringKeyParams["product-country"] as? String
                    expect(productCountry).to(equal(product.postalAddress.countryCode))
                    
                    expect(sut.params!.stringKeyParams["product-zipcode"]).notTo(beNil())
                    let productZipCode = sut.params!.stringKeyParams["product-zipcode"] as? String
                    expect(productZipCode).to(equal(product.postalAddress.zipCode))
                    
                    expect(sut.params!.stringKeyParams["product-city"]).notTo(beNil())
                    let productCity = sut.params!.stringKeyParams["product-city"] as? String
                    expect(productCity).to(equal(product.postalAddress.city))
                    
                    // Product user / the other user
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user!.objectId))
                    
                    // My user
                    
                    expect(sut.params!.stringKeyParams["user-id"]).notTo(beNil())
                    let myUserId = sut.params!.stringKeyParams["user-id"] as? String
                    expect(myUserId).to(equal(myUser.objectId))
                }
            }
        }
    }
}
