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
                    sut = TrackerEvent.signupEmail(.Sell)
                    expect(sut.name.rawValue).to(equal("signup-email"))
                }
                it("contains the appropiate login source signing in via email from posting") {
                    sut = TrackerEvent.signupEmail(.Sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source signing in via email from chats") {
                    sut = TrackerEvent.signupEmail(.Chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source signing in via email from profile") {
                    sut = TrackerEvent.signupEmail(.Profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source signing in via email from mark as favourite") {
                    sut = TrackerEvent.signupEmail(.Favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source signing in via email from make an offer") {
                    sut = TrackerEvent.signupEmail(.MakeOffer)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
                }
                it("contains the appropiate login source signing in via email from mark as sold") {
                    sut = TrackerEvent.signupEmail(.MarkAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source signing in via email from as a question") {
                    sut = TrackerEvent.signupEmail(.AskQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source signing in via email from report fraud") {
                    sut = TrackerEvent.signupEmail(.ReportFraud)
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
            }
            
            describe("searchComplete") {
                it("has its event name") {
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "")
                    expect(sut.name.rawValue).to(equal("search-complete"))
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
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
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
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
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
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
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

                }
            }
            
            describe("productMarkAsSold") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-detail-sold"))
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
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                }
            }

            describe("productSellStart") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellStart(user)
                    expect(sut.name.rawValue).to(equal("product-sell-start"))
                }
            }
            
            describe("productSellFormValidationFailed") {
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellFormValidationFailed(nil, description: "whatever")
                    expect(sut.name.rawValue).to(equal("product-sell-form-validation-failed"))
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
                it("contains the product related params when passing by a product") {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    
                    sut = TrackerEvent.productSellSharedFB(nil, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }

            describe("productSellComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productSellComplete(nil, product: product)
                    expect(sut.name.rawValue).to(equal("product-sell-complete"))
                }
                it("contains the product related params when passing by a product") {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    product.categoryId = NSNumber(integer: 4)
                    
                    sut = TrackerEvent.productSellComplete(nil, product: product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(4))
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditStart") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditStart(user, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-start"))
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
            
            describe("productEditFormValidationFailed") {
                it("has its event name") {
                    let user = MockUser()
                    let product = MockProduct()
                    sut = TrackerEvent.productEditFormValidationFailed(nil, product: product, description: "whatever")
                    expect(sut.name.rawValue).to(equal("product-edit-form-validation-failed"))
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
                    sut = TrackerEvent.productEditSharedFB(nil, product: product)
                    expect(sut.name.rawValue).to(equal("product-edit-shared-fb"))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productEditSharedFB(nil, product: product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productEditComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productEditComplete(nil, product: product, category: nil)
                    expect(sut.name.rawValue).to(equal("product-edit-complete"))
                }
                it("contains the product related params when passing by a product, name & category") {
                    let product = MockProduct()
                    let newCategory = ProductCategory.CarsAndMotors
                    product.objectId = "q1w2e3"

                    sut = TrackerEvent.productEditComplete(nil, product: product, category: newCategory)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(newCategory.rawValue))

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
            
            describe("productDeleteComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDeleteComplete(product, user: nil)
                    expect(sut.name.rawValue).to(equal("product-delete-complete"))
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
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!.doubleValue))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.categoryId!.integerValue))
                    
                    expect(sut.params!.stringKeyParams["product-lat"]).notTo(beNil())
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(product.location!.latitude))
                    
                    expect(sut.params!.stringKeyParams["product-lng"]).notTo(beNil())
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(product.location!.longitude))
                    
                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("real"))
                    
                    // Product user / the other user
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user!.objectId))
                    
                }
            }
        }
    }
}
