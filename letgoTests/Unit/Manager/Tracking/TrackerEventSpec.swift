
import CoreLocation
@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class TrackerEventSpec: QuickSpec {
    
    override func spec() {
        var sut: TrackerEvent!
        var user: MockUser!
        
        describe("factory methods") {
            
            describe("location") {
                context("event name") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "location"
                    }
                }
                context("type sensor") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location type when retrieving from sensors") {
                        expect(sut.params!.stringKeyParams["location-type"] as? String) == "sensor"
                    }
                }
                context("type manual") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .manual,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location type when setting manually") {
                        expect(sut.params!.stringKeyParams["location-type"] as? String) == "manual"
                    }
                }
                context("type iplookup") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .ipLookup,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location type when retrieving from ip lookup") {
                        expect(sut.params!.stringKeyParams["location-type"] as? String) == "iplookup"
                    }
                }
                context("type regional") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .regional,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location type when retrieving regional") {
                        expect(sut.params!.stringKeyParams["location-type"] as? String) == "regional"
                    }
                }
                context("location disabled") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .regional,
                                                    locationServiceStatus: .disabled,
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location enabled false") {
                        expect(sut.params!.stringKeyParams["location-enabled"] as? Bool) == false
                    }
                    it("contains location allowed false") {
                        expect(sut.params!.stringKeyParams["location-allowed"] as? Bool) == false
                    }
                }
                context("location .enabled(.notDetermined)") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .regional,
                                                    locationServiceStatus: .enabled(.notDetermined),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location enabled true") {
                        expect(sut.params!.stringKeyParams["location-enabled"] as? Bool) == true
                    }
                    it("contains location allowed false") {
                        expect(sut.params!.stringKeyParams["location-allowed"] as? Bool) == false
                    }
                }
                context("location .enabled(.restricted)") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .regional,
                                                    locationServiceStatus: .enabled(.restricted),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location enabled true") {
                        expect(sut.params!.stringKeyParams["location-enabled"] as? Bool) == true
                    }
                    it("contains location allowed false") {
                        expect(sut.params!.stringKeyParams["location-allowed"] as? Bool) == false
                    }
                }
                context("location .enabled(.denied)") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .regional,
                                                    locationServiceStatus: .enabled(.denied),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location enabled true") {
                        expect(sut.params!.stringKeyParams["location-enabled"] as? Bool) == true
                    }
                    it("contains location allowed false") {
                        expect(sut.params!.stringKeyParams["location-allowed"] as? Bool) == false
                    }
                }
                context("location .enabled(.authorized)") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .regional,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the location enabled true") {
                        expect(sut.params!.stringKeyParams["location-enabled"] as? Bool) == true
                    }
                    it("contains location allowed true") {
                        expect(sut.params!.stringKeyParams["location-allowed"] as? Bool) == true
                    }
                }
                context("type page filter") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .filter,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the page type filter") {
                        expect(sut.params!.stringKeyParams["type-page"] as? String) == "filter"
                    }
                }
                context("type page profile") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .profile,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the page type profile") {
                        expect(sut.params!.stringKeyParams["type-page"] as? String) == "profile"
                    }
                }
                context("type page feedBubble") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .feedBubble,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the page type feed-bubble") {
                        expect(sut.params!.stringKeyParams["type-page"] as? String) == "feed-bubble"
                    }
                }
                context("type page automatic") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .automatic,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains the page type automatic") {
                        expect(sut.params!.stringKeyParams["type-page"] as? String) == "automatic"
                    }
                }
                context("zipcode is not set") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .feedBubble,
                                                    zipCodeFilled: nil,
                                                    distanceRadius: nil)
                    }
                    it("contains zipcode N/A") {
                        expect(sut.params!.stringKeyParams["zipcode"] as? String) == TrackerEvent.notApply
                    }
                }
                context("zipcode is filled") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .feedBubble,
                                                    zipCodeFilled: true,
                                                    distanceRadius: nil)
                    }
                    it("contains zipcode trueParameter") {
                        expect(sut.params!.stringKeyParams["zipcode"] as? String) == "true"
                    }
                }
                context("zipcode is not filled") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .feedBubble,
                                                    zipCodeFilled: false,
                                                    distanceRadius: nil)
                    }
                    it("contains zipcode falseParameter") {
                        expect(sut.params!.stringKeyParams["zipcode"] as? String) == "false"
                    }
                }
                context("distanceRadius is not set") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .feedBubble,
                                                    zipCodeFilled: false,
                                                    distanceRadius: nil)
                    }
                    it("contains distanceRadius default") {
                        expect(sut.params!.stringKeyParams["distance-radius"] as? String) == "default"
                    }
                }
                context("distanceRadius is set to 1") {
                    beforeEach {
                        sut = TrackerEvent.location(locationType: .sensor,
                                                    locationServiceStatus: .enabled(.authorized),
                                                    typePage: .feedBubble,
                                                    zipCodeFilled: false,
                                                    distanceRadius: 1)
                    }
                    it("contains distanceRadius 1") {
                        expect(sut.params!.stringKeyParams["distance-radius"] as? Int).to(equal(1))
                    }
                }
            }

            describe("loginVisit") {
                it("has its event name") {
                    sut = TrackerEvent.loginVisit(.sell, rememberedAccount: true)
                    expect(sut.name.rawValue).to(equal("login-screen"))
                }
                it("contains the existing param") {
                    sut = TrackerEvent.loginVisit(.sell, rememberedAccount: true)
                    let existing = sut.params!.stringKeyParams["existing"] as! Bool
                    expect(existing) == true
                }
                it("contains the appropiate login source when visiting login from posting") {
                    sut = TrackerEvent.loginVisit(.sell, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source when visiting login from chats") {
                    sut = TrackerEvent.loginVisit(.chats, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source when visiting login from profile") {
                    sut = TrackerEvent.loginVisit(.profile, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source when visiting login from mark as favourite") {
                    sut = TrackerEvent.loginVisit(.favourite, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source when visiting login from mark as sold") {
                    sut = TrackerEvent.loginVisit(.markAsSold, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source when visiting login from as a question") {
                    sut = TrackerEvent.loginVisit(.askQuestion, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source when visiting login from report fraud") {
                    sut = TrackerEvent.loginVisit(.reportFraud, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }
            
            describe("loginAbandon") {
                it("has its event name") {
                    sut = TrackerEvent.loginAbandon(.sell)
                    expect(sut.name.rawValue).to(equal("login-abandon"))
                }
                it("contains the appropiate login source when abandoning login from posting") {
                    sut = TrackerEvent.loginAbandon(.sell)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source when abandoning login from chats") {
                    sut = TrackerEvent.loginAbandon(.chats)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source when abandoning login from profile") {
                    sut = TrackerEvent.loginAbandon(.profile)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source when abandoning login from mark as favourite") {
                    sut = TrackerEvent.loginAbandon(.favourite)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source when abandoning login from mark as sold") {
                    sut = TrackerEvent.loginAbandon(.markAsSold)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source when abandoning login from as a question") {
                    sut = TrackerEvent.loginAbandon(.askQuestion)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source when abandoning login from report fraud") {
                    sut = TrackerEvent.loginAbandon(.reportFraud)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }

            describe("loginFB") {
                it("has its event name") {
                    sut = TrackerEvent.loginFB(.sell, rememberedAccount: true)
                    expect(sut.name.rawValue).to(equal("login-fb"))
                }
                it("contains the existing param") {
                    sut = TrackerEvent.loginFB(.sell, rememberedAccount: true)
                    let existing = sut.params!.stringKeyParams["existing"] as! Bool
                    expect(existing) == true
                }
                it("contains the appropiate login source logging in via FB from posting") {
                    sut = TrackerEvent.loginFB(.sell, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source logging in via FB from chats") {
                    sut = TrackerEvent.loginFB(.chats, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source logging in via FB from profile") {
                    sut = TrackerEvent.loginFB(.profile, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source logging in via FB from mark as favourite") {
                    sut = TrackerEvent.loginFB(.favourite, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source logging in via FB from mark as sold") {
                    sut = TrackerEvent.loginFB(.markAsSold, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source logging in via FB from as a question") {
                    sut = TrackerEvent.loginFB(.askQuestion, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source logging in via FB from report fraud") {
                    sut = TrackerEvent.loginFB(.reportFraud, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }

            describe("loginGoogle") {
                it("has its event name") {
                    sut = TrackerEvent.loginGoogle(.sell, rememberedAccount: true)
                    expect(sut.name.rawValue).to(equal("login-google"))
                }
                it("contains the existing param") {
                    sut = TrackerEvent.loginGoogle(.sell, rememberedAccount: true)
                    let existing = sut.params!.stringKeyParams["existing"] as! Bool
                    expect(existing) == true
                }
                it("contains the appropiate login source logging in via FB from posting") {
                    sut = TrackerEvent.loginGoogle(.sell, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source logging in via FB from chats") {
                    sut = TrackerEvent.loginGoogle(.chats, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source logging in via FB from profile") {
                    sut = TrackerEvent.loginGoogle(.profile, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source logging in via FB from mark as favourite") {
                    sut = TrackerEvent.loginGoogle(.favourite, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source logging in via FB from mark as sold") {
                    sut = TrackerEvent.loginGoogle(.markAsSold, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source logging in via FB from as a question") {
                    sut = TrackerEvent.loginGoogle(.askQuestion, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source logging in via FB from report fraud") {
                    sut = TrackerEvent.loginGoogle(.reportFraud, rememberedAccount: true)
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }


            describe("loginEmail") {
                it("has its event name") {
                    sut = TrackerEvent.loginEmail(.sell, rememberedAccount: true)
                    expect(sut.name.rawValue).to(equal("login-email"))
                }
                it("contains the existing param") {
                    sut = TrackerEvent.loginEmail(.sell, rememberedAccount: true)
                    let existing = sut.params!.stringKeyParams["existing"] as! Bool
                    expect(existing) == true
                }
                it("contains the appropiate login source logging in via email from posting") {
                    sut = TrackerEvent.loginEmail(.sell, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source logging in via email from chats") {
                    sut = TrackerEvent.loginEmail(.chats, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source logging in via email from profile") {
                    sut = TrackerEvent.loginEmail(.profile, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source logging in via email from mark as favourite") {
                    sut = TrackerEvent.loginEmail(.favourite, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source logging in via email from mark as sold") {
                    sut = TrackerEvent.loginEmail(.markAsSold, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source logging in via email from as a question") {
                    sut = TrackerEvent.loginEmail(.askQuestion, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source logging in via email from report fraud") {
                    sut = TrackerEvent.loginEmail(.reportFraud, rememberedAccount: true)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("report-fraud"))
                }
            }
            
            describe("signupEmail") {
                it("has its event name") {
                    sut = TrackerEvent.signupEmail(.sell, newsletter: .notAvailable)
                    expect(sut.name.rawValue).to(equal("signup-email"))
                }
                it("contains the appropiate login source signing in via email from posting") {
                    sut = TrackerEvent.signupEmail(.sell, newsletter: .notAvailable)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source signing in via email from chats") {
                    sut = TrackerEvent.signupEmail(.chats, newsletter: .notAvailable)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source signing in via email from profile") {
                    sut = TrackerEvent.signupEmail(.profile, newsletter: .notAvailable)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source signing in via email from mark as favourite") {
                    sut = TrackerEvent.signupEmail(.favourite, newsletter: .notAvailable)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source signing in via email from mark as sold") {
                    sut = TrackerEvent.signupEmail(.markAsSold, newsletter: .notAvailable)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source signing in via email from as a question") {
                    sut = TrackerEvent.signupEmail(.askQuestion, newsletter: .notAvailable)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source signing in via email from report fraud") {
                    sut = TrackerEvent.signupEmail(.reportFraud, newsletter: .notAvailable)
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

            describe("password reset visit") {
                it("has its event name") {
                    sut = TrackerEvent.passwordResetVisit()
                    expect(sut.name.rawValue).to(equal("login-reset-password"))
                }
            }

            describe("login email error") {
                let error = EventParameterLoginError.internalError(description: "details")
                beforeEach {
                    sut = TrackerEvent.loginEmailError(error)
                    expect(sut.params).notTo(beNil())
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-error"))
                }
                it("contains the error description param") {
                    let description = sut.params!.stringKeyParams["error-description"] as! String
                    expect(description) == error.description
                }
                it("contains the error details param") {
                    let description = sut.params!.stringKeyParams["error-details"] as! String
                    expect(description) == error.details
                }
            }

            describe("login fb error") {
                let error = EventParameterLoginError.internalError(description: "details")
                beforeEach {
                    sut = TrackerEvent.loginFBError(error)
                    expect(sut.params).notTo(beNil())
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-signup-error-facebook"))
                }
                it("contains the error description param") {
                    let description = sut.params!.stringKeyParams["error-description"] as! String
                    expect(description) == error.description
                }
                it("contains the error details param") {
                    let description = sut.params!.stringKeyParams["error-details"] as! String
                    expect(description) == error.details
                }
            }

            describe("login google error") {
                let error = EventParameterLoginError.internalError(description: "details")
                beforeEach {
                    sut = TrackerEvent.loginGoogleError(error)
                    expect(sut.params).notTo(beNil())
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-signup-error-google"))
                }
                it("contains the error description param") {
                    let description = sut.params!.stringKeyParams["error-description"] as! String
                    expect(description) == error.description
                }
                it("contains the error details param") {
                    let description = sut.params!.stringKeyParams["error-details"] as! String
                    expect(description) == error.details
                }
            }

            describe("Login Blocked Account Start") {
                beforeEach {
                    sut = TrackerEvent.loginBlockedAccountStart(.email, reason: .accountUnderReview)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-blocked-account-start"))
                }
                it("contains the Account network parameter") {
                    let network = sut.params!.stringKeyParams["account-network"] as! String
                    expect(network) == "email"
                }
                it("contains the reason parameter") {
                    let network = sut.params!.stringKeyParams["reason"] as! String
                    expect(network) == "account-under-review"
                }
            }

            describe("Login Blocked Account Contact us") {
                beforeEach {
                    sut = TrackerEvent.loginBlockedAccountContactUs(.email, reason: .accountUnderReview)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-blocked-account-contact-us"))
                }
                it("contains the Account network parameter") {
                    let network = sut.params!.stringKeyParams["account-network"] as! String
                    expect(network) == "email"
                }
                it("contains the reason parameter") {
                    let network = sut.params!.stringKeyParams["reason"] as! String
                    expect(network) == "account-under-review"
                }
            }

            describe("Login Blocked Account Keep browsing") {
                beforeEach {
                    sut = TrackerEvent.loginBlockedAccountKeepBrowsing(.email, reason: .accountUnderReview)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-blocked-account-keep-browsing"))
                }
                it("contains the Account network parameter") {
                    let network = sut.params!.stringKeyParams["account-network"] as! String
                    expect(network) == "email"
                }
                it("contains the reason parameter") {
                    let network = sut.params!.stringKeyParams["reason"] as! String
                    expect(network) == "account-under-review"
                }
            }

            describe("signup error") {
                let error = EventParameterLoginError.internalError(description: "details")
                beforeEach {
                    sut = TrackerEvent.signupError(error)
                    expect(sut.params).notTo(beNil())
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("signup-error"))
                }
                it("contains the error description param") {
                    let description = sut.params!.stringKeyParams["error-description"] as! String
                    expect(description) == error.description
                }
                it("contains the error details param") {
                    let description = sut.params!.stringKeyParams["error-details"] as! String
                    expect(description) == error.details
                }
            }
            
            describe("password reset error error") {
                let error = EventParameterLoginError.internalError(description: "details")
                beforeEach {
                    sut = TrackerEvent.passwordResetError(error)
                    expect(sut.params).notTo(beNil())
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("password-reset-error"))
                }
                it("contains the error description param") {
                    let description = sut.params!.stringKeyParams["error-description"] as! String
                    expect(description) == error.description
                }
                it("contains the error details param") {
                    let description = sut.params!.stringKeyParams["error-details"] as! String
                    expect(description) == error.details
                }
            }
            
            describe("listingList") {
                let categories: [ListingCategory] = [.homeAndGarden, .motorsAndAccessories]
                let taxonomy: TaxonomyChild = MockTaxonomyChild.makeMock()
                let searchQuery = "iPhone"
                let count = Int.random()

                beforeEach {
                    sut = TrackerEvent.listingList(nil, categories: categories, taxonomy: taxonomy, searchQuery: searchQuery, resultsCount: count, feedSource: .home, success: .trueParameter)
                }
                
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-list"))
                }
                it("contains the category related params when passing by several categories") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("4,2"))
                }
                it("contains the search query related params when passing by a search query") {
                    let searchKeyword = sut.params!.stringKeyParams["search-keyword"] as? String
                    expect(searchKeyword).to(equal(searchQuery))
                }
                it("contains feed source parameter") {
                    expect(sut.params!.stringKeyParams["feed-source"] as? String).to(equal("home"))
                }
                it("contains list-success parameter") {
                    let listSuccess = sut.params!.stringKeyParams["list-success"] as? String
                    expect(listSuccess).to(equal("true"))
                }
                it("contains keyword-name parameter") {
                    expect(sut.params!.stringKeyParams["keyword-name"] as? String).to(equal(taxonomy.name))
                }
                it("contains number-of-items parameter") {
                    if count >= 50 {
                        expect(sut.params!.stringKeyParams["number-of-items"] as? String).to(equal("50"))
                    } else {
                        expect(sut.params!.stringKeyParams["number-of-items"] as? String).to(equal("\(count)"))
                    }
                }
            }
            
            describe("listingListVertical") {
                beforeEach {
                    sut = TrackerEvent.listingListVertical(category: .cars,
                                                           keywords: ["kw1", "kw2"],
                                                           matchingFields: ["mf1", "mf2"],
                                                           nonMatchingFields: ["nmf1", "nmf2"])
                }
                
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-list-vertical"))
                }
                it("contains the category id parameter") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("9"))
                }
                it("contains vertical keyword parameter") {
                    expect(sut.params!.stringKeyParams["vertical-keyword"] as? String) == "kw1_kw2"
                }
                it("contains vertical matching fields parameter") {
                    expect(sut.params!.stringKeyParams["vertical-matching-fields"] as? String) == "mf1,mf2"
                }
                it("contains vertical no  matching fields parameter") {
                    expect(sut.params!.stringKeyParams["vertical-no-matching-fields"] as? String) == "nmf1,nmf2"
                }
            }

            describe("searchStart") {
                it("has its event name") {
                    sut = TrackerEvent.searchStart(nil)
                    expect(sut.name.rawValue).to(equal("search-start"))
                }
            }
            
            describe("searchComplete") {
                context("isLastSearch") {
                    context("success") {
                        beforeEach {
                            sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .success, isLastSearch: true, isSuggestiveSearch: false, suggestiveSearchIndex: nil)
                        }
                        it("has its event name") {
                            expect(sut.name.rawValue).to(equal("search-complete"))
                        }
                        it("contains the isTrending parameter") {
                            let searchQuery = sut.params!.stringKeyParams["trending-search"] as? Bool
                            expect(searchQuery) == false
                        }
                        it("contains the isLastSearch parameter") {
                            let searchQuery = sut.params!.stringKeyParams["last-search"] as? Bool
                            expect(searchQuery) == true
                        }
                        it("contains the isSuggestiveSearch parameter") {
                            let searchQuery = sut.params!.stringKeyParams["search-suggestion"] as? Bool
                            expect(searchQuery) == false
                        }
                        it("does not contain the suggestiveSearchIndex parameter") {
                            expect(sut.params!.stringKeyParams["search-suggestion-position"]).to(beNil())
                        }
                        it("contains the search keyword related params when passing by the search query") {
                            let searchQuery = sut.params!.stringKeyParams["search-keyword"] as? String
                            expect(searchQuery) == "iPhone"
                        }
                        it("search is success") {
                            let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                            expect(searchSuccess) == "yes"
                        }
                    }
                    context("failure") {
                        beforeEach {
                            sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .fail, isLastSearch: true, isSuggestiveSearch: false, suggestiveSearchIndex: nil)
                        }
                        it("search with no success") {
                            let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                            expect(searchSuccess) == "no"
                        }
                    }
                }
                context("isSuggestiveSearch") {
                    context("success") {
                        beforeEach {
                            sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .success, isLastSearch: false, isSuggestiveSearch: true, suggestiveSearchIndex: 0)
                        }
                        it("has its event name") {
                            expect(sut.name.rawValue).to(equal("search-complete"))
                        }
                        it("contains the isTrending parameter") {
                            let searchQuery = sut.params!.stringKeyParams["trending-search"] as? Bool
                            expect(searchQuery) == false
                        }
                        it("contains the isLastSearch parameter") {
                            let searchQuery = sut.params!.stringKeyParams["last-search"] as? Bool
                            expect(searchQuery) == false
                        }
                        it("contains the isSuggestiveSearch parameter") {
                            let searchQuery = sut.params!.stringKeyParams["search-suggestion"] as? Bool
                            expect(searchQuery) == true
                        }
                        it("contains the suggestiveSearchIndex parameter") {
                            let suggestiveSearchIndex = sut.params!.stringKeyParams["search-suggestion-position"] as? Int
                            expect(suggestiveSearchIndex) == 0
                        }
                        it("contains the search keyword related params when passing by the search query") {
                            let searchQuery = sut.params!.stringKeyParams["search-keyword"] as? String
                            expect(searchQuery) == "iPhone"
                        }
                        it("search is success") {
                            let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                            expect(searchSuccess) == "yes"
                        }
                    }
                    context("failure") {
                        beforeEach {
                            sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .fail, isLastSearch: false, isSuggestiveSearch: true, suggestiveSearchIndex: 0)
                        }
                        it("search with no success") {
                            let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                            expect(searchSuccess) == "no"
                        }
                    }
                }
            }

            describe("filterStart") {
                it("has its event name") {
                    sut = TrackerEvent.filterStart()
                    expect(sut.name.rawValue).to(equal("filter-start"))
                }
            }

            describe("filterLocationStart") {
                beforeEach {
                    sut = TrackerEvent.filterLocationStart()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("filter-location-start"))
                }
            }

            describe("filterComplete") {
                context("receiving all params") {
                    beforeEach {
                        let coords = LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123)
                        sut = TrackerEvent.filterComplete(coords, distanceRadius: 10, distanceUnit: DistanceType.km,
                            categories: [.electronics, .motorsAndAccessories],
                            sortBy: ListingSortCriteria.distance, postedWithin: ListingTimeCriteria.day,
                            priceRange: .priceRange(min: 5, max: 100), freePostingModeAllowed: true, carMake: "make",
                            carModel: "model", carYearStart: 1990, carYearEnd: 2000)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("filter-complete"))
                    }
                    it("has coords info") {
                        expect(sut.params!.stringKeyParams["filter-lat"]).notTo(beNil())
                        let lat = sut.params!.stringKeyParams["filter-lat"] as? Double
                        expect(lat).to(equal(41.123))

                        expect(sut.params!.stringKeyParams["filter-lng"]).notTo(beNil())
                        let lng = sut.params!.stringKeyParams["filter-lng"] as? Double
                        expect(lng).to(equal(2.123))
                    }
                    it("distance radius") {
                        expect(sut.params!.stringKeyParams["distance-radius"] as? Int).to(equal(10))
                    }
                    it("distance unit") {
                        expect(sut.params!.stringKeyParams["distance-unit"] as? String).to(equal("km"))
                    }
                    it("has categories") {
                        let categories = sut.params!.stringKeyParams["category-id"] as? String 
                        expect(categories).to(equal("1,2"))
                    }
                    it("has sort by") {
                        expect(sut.params!.stringKeyParams["sort-by"] as? String).to(equal("distance"))
                    }
                    it("has posted within") {
                        expect(sut.params!.stringKeyParams["posted-within"] as? String).to(equal("day"))
                    }
                    it("min price") {
                        expect(sut.params!.stringKeyParams["price-from"] as? String) == "true"
                    }
                    it("max price") {
                        expect(sut.params!.stringKeyParams["price-to"] as? String) == "true"
                    }
                    it ("free-posting") {
                        expect(sut.params!.stringKeyParams["free-posting"] as? String) == "false"
                    }
                    it ("make") {
                        expect(sut.params!.stringKeyParams["product-make"] as? String) == "make"
                    }
                    it ("model") {
                        expect(sut.params!.stringKeyParams["product-model"] as? String) == "model"
                    }
                    it ("start") {
                        expect(sut.params!.stringKeyParams["product-year-start"] as? String) == "1990"
                    }
                    it ("end") {
                        expect(sut.params!.stringKeyParams["product-year-end"] as? String) == "2000"
                    }
                    it ("vertical fields") {
                        expect(sut.params!.stringKeyParams["vertical-fields"] as? String) == "product-make,product-model,product-year-start,product-year-end"
                    }
                }
                context("not receiving all params, contains the default params") {
                    beforeEach {
                        sut = TrackerEvent.filterComplete(nil, distanceRadius: nil, distanceUnit: DistanceType.km,
                            categories: nil, sortBy: nil, postedWithin: nil, priceRange: .priceRange(min: nil, max: nil),
                            freePostingModeAllowed: false, carMake: nil,
                            carModel: nil, carYearStart: nil, carYearEnd: nil)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("filter-complete"))
                    }
                    it("default coords") {
                        expect(sut.params!.stringKeyParams["filter-lat"]).notTo(beNil())
                        let lat = sut.params!.stringKeyParams["filter-lat"] as? String
                        expect(lat).to(equal("default"))

                        expect(sut.params!.stringKeyParams["filter-lng"]).notTo(beNil())
                        let lng = sut.params!.stringKeyParams["filter-lat"] as? String
                        expect(lng).to(equal("default"))
                    }
                    it("distance radius") {
                        expect(sut.params!.stringKeyParams["distance-radius"] as? String).to(equal("default"))
                    }
                    it("distance unit") {
                        expect(sut.params!.stringKeyParams["distance-unit"] as? String).to(equal("km"))
                    }
                    it("categories") {
                        let categories = sut.params!.stringKeyParams["category-id"] as? String
                        expect(categories).to(equal("0"))
                    }
                    it("doesn't have sort by") {
                        expect(sut.params!.stringKeyParams["sort-by"] as? String).to(beNil())
                    }
                    it("doesn't have within") {
                        expect(sut.params!.stringKeyParams["posted-within"] as? String).to(beNil())
                    }
                    it("min price") {
                        expect(sut.params!.stringKeyParams["price-from"] as? String) == "false"
                    }
                    it("max price") {
                        expect(sut.params!.stringKeyParams["price-to"] as? String) == "false"
                    }
                    it("free posting") {
                        expect(sut.params!.stringKeyParams["free-posting"] as? String) == TrackerEvent.notApply
                    }
                    it ("make") {
                        expect(sut.params!.stringKeyParams["product-make"] as? String) == TrackerEvent.notApply
                    }
                    it ("model") {
                        expect(sut.params!.stringKeyParams["product-model"] as? String) == TrackerEvent.notApply
                    }
                    it ("start") {
                        expect(sut.params!.stringKeyParams["product-year-start"] as? String) == TrackerEvent.notApply
                    }
                    it ("end") {
                        expect(sut.params!.stringKeyParams["product-year-end"] as? String) == TrackerEvent.notApply
                    }

                    it ("vertical fields") {
                        expect(sut.params!.stringKeyParams["vertical-fields"] as? String) == TrackerEvent.notApply
                    }
                }
            }
            
            describe("listingDetailVisit") {
                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false

                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                                                          state: "Catalonia", countryCode: "US", country: nil)

                    sut = TrackerEvent.listingDetailVisit(.product(product), visitUserAction: .none, source: .listingList,
                                                          feedPosition: .position(index:1), isBumpedUp: .trueParameter)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-visit"))
                }
                it("contains user action") {
                    let userAction = sut.params!.stringKeyParams["user-action"] as? String
                    expect(userAction) == TrackerEvent.notApply
                }
                it("contains source") {
                    let source = sut.params!.stringKeyParams["visit-source"] as? String
                    expect(source) == "product-list"
                }
                it("contains product id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("AAAAA"))
                }
                it("contains product price") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(Double(123.2)))
                }
                it("contains product currency") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal("EUR"))
                }
                it("contains category") {
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(4))
                }
                it("contains latitude and longitude") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(3.12354534))
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(7.23983292))
                }
                it("contains user id") {
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal("56897"))
                }
                it("contains item type") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("1"))
                }
                it("contains feed-position") {
                    let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                    expect(feedPosition).to(equal("2"))
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp).to(equal("true"))
                }
            }
            
            describe("listingDetailVisitMoreInfo") {
                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.isDummy = false

                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)

                    sut = TrackerEvent.listingDetailVisitMoreInfo(.product(product),
                                                                  isMine: .falseParameter,
                                                                  adShown: .falseParameter,
                                                                  adType: nil,
                                                                  queryType: nil,
                                                                  query: nil,
                                                                  visibility: nil,
                                                                  errorReason: nil)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-visit-more-info"))
                }
                it("contains product id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("AAAAA"))
                }
                it("contains product price") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(Double(123.2)))
                }
                it("contains product currency") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal("EUR"))
                }
                it("contains category") {
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(4))
                }
                it("contains latitude and longitude") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(3.12354534))
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(7.23983292))
                }
                it("contains user id") {
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal("56897"))
                }
                it("contains item type") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("1"))
                }
                it("contains is-mine false") {
                    expect(sut.params!.stringKeyParams["is-mine"] as? String) == "false"
                }
                it("contains ad-shown false") {
                    expect(sut.params!.stringKeyParams["ad-shown"] as? String) == "false"
                }
                it("contains ad-type N/A") {
                    expect(sut.params!.stringKeyParams["ad-type"] as? String) == TrackerEvent.notApply
                }
                it("contains ad-query-type N/A") {
                    expect(sut.params!.stringKeyParams["ad-query-type"] as? String) == TrackerEvent.notApply
                }
                it("contains ad-query-text N/A") {
                    expect(sut.params!.stringKeyParams["ad-query-text"] as? String) == TrackerEvent.notApply
                }
                it("contains ad-visibility N/A") {
                    expect(sut.params!.stringKeyParams["ad-visibility"] as? String) == TrackerEvent.notApply
                }
                it("contains reason N/A") {
                    expect(sut.params!.stringKeyParams["reason"] as? String) == TrackerEvent.notApply
                }
            }

            describe("listingDetailCall") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"

                    sut = TrackerEvent.listingDetailCall(.product(product), source: .listingList,
                                                         typePage: .listingDetail, sellerAverageUserRating: 2.5,
                                                         feedPosition: .position(index:1), isFreePosting: .falseParameter,
                                                         isBumpedUp: .trueParameter)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-call"))
                }
                it("contains listing id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("AAAAA"))
                }
                it("contains source") {
                    let source = sut.params!.stringKeyParams["visit-source"] as? String
                    expect(source).to(equal("product-list"))
                }
                it("contains type-page") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("product-detail"))
                }
                it("contains seller rating") {
                    let rating = sut.params!.stringKeyParams["seller-user-rating"] as? Float
                    expect(rating).to(equal(2.5))
                }
                it("contains feed position") {
                    let position = sut.params!.stringKeyParams["feed-position"] as? String
                    expect(position).to(equal("2"))
                }
                it("contains is free posting") {
                    let isFree = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(isFree).to(equal("false"))
                }
                it("contains is bumped up") {
                    let isBumped = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(isBumped).to(equal("true"))
                }
            }

            describe("chatBannerCall") {
                beforeEach {
                    var chatListing = MockChatListing.makeMock()
                    chatListing.objectId = "AAAAA"

                    sut = TrackerEvent.chatBannerCall(chatListing, source: .unknown,
                                                      typePage: .chat, sellerAverageUserRating: 2.5,
                                                      isFreePosting: .falseParameter,
                                                      isBumpedUp: .falseParameter)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-call"))
                }
                it("contains listing id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("AAAAA"))
                }
                it("contains source") {
                    let source = sut.params!.stringKeyParams["visit-source"] as? String
                    expect(source).to(equal("N/A"))
                }
                it("contains type-page") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("chat"))
                }
                it("contains seller rating") {
                    let rating = sut.params!.stringKeyParams["seller-user-rating"] as? Float
                    expect(rating).to(equal(2.5))
                }
                it("contains feed position, and is always N/A") {
                    let position = sut.params!.stringKeyParams["feed-position"] as? String
                    expect(position).to(equal("N/A"))
                }
                it("contains is free posting") {
                    let isFree = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(isFree).to(equal("false"))
                }
                it("contains is bumped up") {
                    let isBumped = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(isBumped).to(equal("false"))
                }
            }

            describe("adTapped") {
                beforeEach {
                    sut = TrackerEvent.adTapped(listingId: "listing123",
                                                adType: .shopping,
                                                isMine: .falseParameter,
                                                queryType: .title,
                                                query: "patata",
                                                willLeaveApp: .trueParameter,
                                                typePage: .listingDetailMoreInfo,
                                                categories: [.homeAndGarden, .motorsAndAccessories],
                                                feedPosition: .position(index: 14))
                }
                it("contains product id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("listing123"))
                }
                it("contains ad-type N/A") {
                    expect(sut.params!.stringKeyParams["ad-type"] as? String) == "shopping"
                }
                it("contains is-mine false") {
                    expect(sut.params!.stringKeyParams["is-mine"] as? String) == "false"
                }
                it("contains ad-query-type title") {
                    expect(sut.params!.stringKeyParams["ad-query-type"] as? String) == "title"
                }
                it("contains ad-query-text") {
                    expect(sut.params!.stringKeyParams["ad-query-text"] as? String) == "patata"
                }
                it("contains will leave app true") {
                    expect(sut.params!.stringKeyParams["left-application"] as? String) == "true"
                }
                it("contains type page") {
                    expect(sut.params!.stringKeyParams["type-page"] as? String) == "product-detail-more-info"
                }
                it("contains categories") {
                    expect(sut.params!.stringKeyParams["category-id"] as? String) == "4,2"
                }
                it("contains feed position") {
                    expect(sut.params!.stringKeyParams["feed-position"] as? String) == "15"
                }
            }
            describe("listingNotAvailable") {
                beforeEach {
                    sut = TrackerEvent.listingNotAvailable(.notifications, reason: .notFound)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-not-available"))
                }
                it("contains visit-source") {
                    let productId = sut.params!.stringKeyParams["visit-source"] as? String
                    expect(productId).to(equal("notifications"))
                }
                it("contains reason") {
                    let productId = sut.params!.stringKeyParams["not-available-reason"] as? String
                    expect(productId).to(equal("not-found"))
                }
            }

            describe("listingFavorite") {

                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false
                    
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.listingFavorite(.product(product), typePage: .listingDetail, isBumpedUp: .trueParameter)
                    expect(sut.params).notTo(beNil())
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-favorite"))
                }
                it("contains product id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("AAAAA"))
                }
                it("contains product price") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(Double(123.983)))
                }
                it("contains product currency") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal("EUR"))
                }
                it("contains category") {
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(4))
                }
                it("contains latitude and longitude") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(3.12354534))
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(7.23983292))
                }
                it("contains user id") {
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal("56897"))
                }
                it("contains item type") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("1"))
                }
                it("contains type page") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("product-detail"))
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp).to(equal("true"))
                }
            }
            
            describe("listingShare") {
                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false
                    
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.listingShare(.product(product), network: .facebook, buttonPosition: .top
                        , typePage: .listingDetail, isBumpedUp: .falseParameter)
                    expect(sut.params).notTo(beNil())
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-share"))
                }
                it("contains product id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("AAAAA"))
                }
                it("contains product price") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(Double(123.983)))
                }
                it("contains product currency") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal("EUR"))
                }
                it("contains category") {
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(4))
                }
                it("contains latitude and longitude") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(3.12354534))
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(7.23983292))
                }
                it("contains user id") {
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal("56897"))
                }
                it("contains item type") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("1"))
                }
                it("contains the network where the content has been shared") {
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the position of the button used to share") {
                    let buttonPosition = sut.params!.stringKeyParams["button-position"] as? String
                    expect(buttonPosition).to(equal("top"))
                }
                it("contains type page") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("product-detail"))
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp).to(equal("false"))
                }
            }
            
            describe("listingShareCancel") {
                var product: MockProduct!
                var event: TrackerEvent!
                beforeEach {
                    product = MockProduct.makeMock()
                    var user = MockUserListing.makeMock()
                    user.objectId = "ABCDE"
                    user.isDummy = false

                    product.user = user
                    product.objectId = "123ABC"
                    event = TrackerEvent.listingShareCancel(.product(product), network: .facebook, typePage: .listingDetail)
                }
                it("has the correct event name") {
                    expect(event.name.rawValue) == "product-detail-share-cancel"
                }
                it("has non nil params") {
                    expect(event.params).toNot(beNil())
                }
                it("contains the item-type param") {
                    let itemType = event.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains the network where the content has been shared") {
                    let network = event.params!.stringKeyParams["share-network"] as? String
                    expect(network) == "facebook"
                }
                it("contains the product being shared") {
                    let productId = event.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "123ABC"
                }
                it("contains the product owner user id") {
                    let userToId = event.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == product.user.objectId
                }
            }
            
            describe("listingShareComplete") {
                var product: MockProduct!
                var event: TrackerEvent!
                beforeEach {
                    product = MockProduct.makeMock()
                    var user = MockUserListing.makeMock()
                    user.objectId = "ABCDE"
                    user.isDummy = false
                    product.user = user
                    product.objectId = "123ABC"
                    event = TrackerEvent.listingShareComplete(.product(product), network: .facebook, typePage: .listingDetail)
                }
                it("has the correct event name") {
                    expect(event.name.rawValue) == "product-detail-share-complete"
                }
                it("has non nil params") {
                    expect(event.params).toNot(beNil())
                }
                it("contains the item-type param") {
                    let itemType = event.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains the network where the content has been shared") {
                    let network = event.params!.stringKeyParams["share-network"] as? String
                    expect(network) == "facebook"
                }
                it("contains the product being shared") {
                    let productId = event.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "123ABC"
                }
                it("contains the product owner user id") {
                    let userToId = event.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == product.user.objectId
                }
            }

            describe("firstMessage") {
                var listing: Listing!
                var sendMessageInfo: SendMessageTrackingInfo!
                beforeEach {
                    
                    var mockProduct = MockProduct.makeMock()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .normal(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")
                    mockProduct.category = .homeAndGarden
                    
                    var productOwner = MockUserListing.makeMock()
                    productOwner.objectId = "67890"
                    productOwner.isDummy = false
                    mockProduct.user = productOwner
                    mockProduct.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    
                    listing = Listing.product(mockProduct)
                    sendMessageInfo = SendMessageTrackingInfo()
                        .set(listing: listing, freePostingModeAllowed: true)
                        .set(messageType: .text)
                        .set(quickAnswerType: nil)
                        .set(typePage: .listingDetail)
                        .set(sellerRating: 4)
                        .set(isBumpedUp: .trueParameter)
                    sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                    listingVisitSource: .listingList,
                                                    feedPosition: .position(index:1))
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-ask-question"))
                }
                it("contains product-id param") {
                    let listingId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(listingId) == listing.objectId
                }
                it("contains product-price param") {
                    let listingPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(listingPrice) == listing.price.value
                }
                it("contains product-currency param") {
                    let listingCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(listingCurrency) == listing.currency.code
                }
                it("contains category-id param") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId) == listing.category.rawValue
                }
                it("contains product-lat param") {
                    let listingLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(listingLat) == listing.location.latitude
                }
                it("contains product-lng param") {
                    let listingLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(listingLng) == listing.location.longitude
                }
                it("contains user-to-id param") {
                    let userToId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == listing.user.objectId
                }
                it("contains item-type param") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains type-page param") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage) == "product-detail"
                }
                it("contains seller-user-rating param") {
                    let typePage = sut.params!.stringKeyParams["seller-user-rating"] as? Float
                    expect(typePage) == 4
                }
                it("contains free-posting param") {
                    let freePosting = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePosting) == "false"
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp) == "true"
                }
                it("contains product visit source") {
                    let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                    expect(visitSource) == "product-list"
                }
                it("contains feed-position") {
                    let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                    expect(feedPosition).to(equal("2"))
                }
                describe("text message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .text)
                        sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                        listingVisitSource: .listingList,
                                                        feedPosition: .position(index:1))
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "text"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                    it("contains product visit source") {
                        let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                        expect(visitSource) == "product-list"
                    }
                    it("contains feed-position") {
                        let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                        expect(feedPosition).to(equal("2"))
                    }
                }
                describe("sticker message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .sticker)
                        sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                        listingVisitSource: .listingList,
                                                        feedPosition: .position(index:1))
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "sticker"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                    it("contains product visit source") {
                        let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                        expect(visitSource) == "product-list"
                    }
                    it("contains feed-position") {
                        let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                        expect(feedPosition).to(equal("2"))
                    }
                }
                describe("quick answer message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .quickAnswer)
                        sendMessageInfo.set(quickAnswerType: .notInterested)
                        sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                        listingVisitSource: .listingList,
                                                        feedPosition: .position(index:1))
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "quick-answer"
                    }
                    it("has no quick-answer-type") {
                        let value = sut.params!.stringKeyParams["quick-answer-type"] as? String
                        expect(value) == "not-interested"
                    }
                    it("contains product visit source") {
                        let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                        expect(visitSource) == "product-list"
                    }
                    it("contains feed-position") {
                        let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                        expect(feedPosition).to(equal("2"))
                    }
                }
            }

            describe("firstMessage (ChatListing)") {
                var product: ChatListing!
                var sendMessageInfo: SendMessageTrackingInfo!
                beforeEach {
                    var mockProduct = MockChatListing.makeMock()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .normal(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")

                    product = mockProduct
                    sendMessageInfo = SendMessageTrackingInfo()
                        .set(chatListing: product, freePostingModeAllowed: true)
                        .set(interlocutorId: "67890")
                        .set(messageType: .text)
                        .set(quickAnswerType: nil)
                        .set(typePage: .listingDetail)
                        .set(sellerRating: 4)
                        .set(isBumpedUp: .trueParameter)
                    sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                    listingVisitSource: .listingList,
                                                    feedPosition: .position(index:1))
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-ask-question"))
                }
                it("contains product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == product.objectId
                }
                it("contains product-price param") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice) == product.price.value
                }
                it("contains product-currency param") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency) == product.currency.code
                }
                it("contains user-to-id param") {
                    let userToId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == "67890"
                }
                it("contains item-type param") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains type-page param") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage) == "product-detail"
                }
                it("contains seller-user-rating param") {
                    let userRating = sut.params!.stringKeyParams["seller-user-rating"] as? Float
                    expect(userRating) == 4
                }
                it("contains free posting param") {
                    let freePosting = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePosting) == "false"
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp) == "true"
                }
                it("contains product visit source") {
                    let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                    expect(visitSource) == "product-list"
                }
                it("contains feed-position") {
                    let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                    expect(feedPosition).to(equal("2"))
                }
                describe("text message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .text)
                        sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                        listingVisitSource: .listingList,
                                                        feedPosition: .position(index:1))
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "text"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                    it("contains product visit source") {
                        let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                        expect(visitSource) == "product-list"
                    }
                    it("contains feed-position") {
                        let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                        expect(feedPosition).to(equal("2"))
                    }
                }
                describe("sticker message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .sticker)
                        sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                        listingVisitSource: .listingList,
                                                        feedPosition: .position(index:1))
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "sticker"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                    it("contains product visit source") {
                        let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                        expect(visitSource) == "product-list"
                    }
                    it("contains feed-position") {
                        let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                        expect(feedPosition).to(equal("2"))
                    }
                }
                describe("quick answer message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .quickAnswer)
                        sendMessageInfo.set(quickAnswerType: .notInterested)
                        sut = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                        listingVisitSource: .listingList,
                                                        feedPosition: .position(index:1))
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "quick-answer"
                    }
                    it("has no quick-answer-type") {
                        let value = sut.params!.stringKeyParams["quick-answer-type"] as? String
                        expect(value) == "not-interested"
                    }
                    it("contains product visit source") {
                        let visitSource = sut.params!.stringKeyParams["visit-source"] as? String
                        expect(visitSource) == "product-list"
                    }
                    it("contains feed-position") {
                        let feedPosition = sut.params!.stringKeyParams["feed-position"] as? String
                        expect(feedPosition).to(equal("2"))
                    }
                }
            }

            describe("listingDetailOpenChat") {
                beforeEach {
                    var mockProduct = MockProduct.makeMock()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .normal(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")

                    sut = TrackerEvent.listingDetailOpenChat(.product(mockProduct), typePage: .listingDetail)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-open-chat"))
                }
                it("contains product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "12345"
                }
                it("contains type-page param") {
                    let productPrice = sut.params!.stringKeyParams["type-page"] as? String
                    expect(productPrice) == "product-detail"
                }
            }

            describe("listingMarkAsSold") {
                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false

                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .free
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)

                    let trackingInfo = MarkAsSoldTrackingInfo.make(listing: .product(product),
                                                                   isBumpedUp: .trueParameter,
                                                                   isFreePostingModeAllowed: true,
                                                                   typePage: .listingDetail)
                    sut = TrackerEvent.listingMarkAsSold(trackingInfo: trackingInfo)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-sold"))
                }
                it("type-page param is included with value product-detail") {
                    expect(sut.params!.stringKeyParams["type-page"] as? String) == "product-detail"
                }
                it("free-posting param is included as Free") {
                    expect(sut.params!.stringKeyParams["free-posting"] as? String) == "true"
                }
                it("contains product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "AAAAA"
                }
                it("contains product-price param") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice) == Double(0)
                }
                it("contains product-currency param") {
                    let value = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(value) == "EUR"
                }
                it("contains category-id param") {
                    let value = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(value) == ListingCategory.homeAndGarden.rawValue
                }
                it("contains free posting param") {
                    let freePosting = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePosting) == "true"
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp) == "true"
                }
            }
            
            describe("listingMarkAsSoldAtLetgo") {
                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false
                    
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .free
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)
                    let trackingInfo = MarkAsSoldTrackingInfo.make(listing: .product(product),
                                                                   isBumpedUp: .trueParameter,
                                                                   isFreePostingModeAllowed: true,
                                                                   typePage: .listingDetail).updating(buyerId: "buyerId")
                    sut = TrackerEvent.listingMarkAsSoldAtLetgo(trackingInfo: trackingInfo)
                }
                
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-sold-at-letgo"))
                }
                it("contains product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "AAAAA"
                }
                it("contains category-id param") {
                    let value = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(value) == ListingCategory.homeAndGarden.rawValue
                }
                it("contains product-price param") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice) == Double(0)
                }
                it("contains product-currency param") {
                    let value = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(value) == "EUR"
                }
                it("free-posting param is included as Free") {
                    expect(sut.params!.stringKeyParams["free-posting"] as? String) == "true"
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp) == "true"
                }
                it("contains user-sold-to param") {
                    let userSoldTo = sut.params!.stringKeyParams["user-sold-to"] as? String
                    expect(userSoldTo) == "buyerId"
                }
            }
            
            describe("listingMarkAsSoldOutsideLetgo") {
                beforeEach {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false
                    
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .free
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)
                    
                    let trackingInfo = MarkAsSoldTrackingInfo.make(listing: .product(product),
                                                                   isBumpedUp: .trueParameter,
                                                                   isFreePostingModeAllowed: true,
                                                                   typePage: .listingDetail)
                    sut = TrackerEvent.listingMarkAsSoldOutsideLetgo(trackingInfo: trackingInfo)
                }
                
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-sold-outside-letgo"))
                }
                it("type-page param is included with value product-detail") {
                    expect(sut.params!.stringKeyParams["type-page"] as? String) == "product-detail"
                }
                it("contains product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "AAAAA"
                }
                it("contains category-id param") {
                    let value = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(value) == ListingCategory.homeAndGarden.rawValue
                }
                it("contains product-price param") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice) == Double(0)
                }
                it("contains product-currency param") {
                    let value = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(value) == "EUR"
                }
                it("free-posting param is included as Free") {
                    expect(sut.params!.stringKeyParams["free-posting"] as? String) == "true"
                }
                it("contains bumped up param") {
                    let bumpedUp = sut.params!.stringKeyParams["bump-up"] as? String
                    expect(bumpedUp) == "true"
                }
            }

            describe("listingMarkAsUnsold") {
                it("has its event name") {
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingMarkAsUnsold(.product(product))
                    expect(sut.name.rawValue).to(equal("product-detail-unsold"))
                }
                it("contains the product related params when passing by a product and my user") {
                    var myUser = MockUserListing.makeMock()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)
                    
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = ListingCategory(rawValue: 4)!
                    product.user = myUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    product.category = ListingCategory(rawValue: 4)!
                    
                    sut = TrackerEvent.listingMarkAsUnsold(.product(product))
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price.value))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.category.rawValue))
                }
            }
            
            describe("listingReport") {
                it("has its event name") {
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingReport(.product(product))
                    expect(sut.name.rawValue).to(equal("product-detail-report"))
                }
                it("contains the product related params when passing by a product and my user") {
                    var userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false
                    
                    var product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.listingReport(.product(product))
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price.value))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.category.rawValue))
                    
                    expect(sut.params!.stringKeyParams["product-lat"]).notTo(beNil())
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat).to(equal(product.location.latitude))
                    
                    expect(sut.params!.stringKeyParams["product-lng"]).notTo(beNil())
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng).to(equal(product.location.longitude))
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user.objectId))
                    
                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("1"))
                    
                }
            }

            describe("listingSellStart") {
                beforeEach {
                    sut = TrackerEvent.listingSellStart(.sell, buttonName: .sellYourStuff,
                        sellButtonPosition: .tabBar, category: .cars)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-start"))
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("product-sell"))
                }
                it("contains button name from which the event has been sent") {
                    let name = sut.params!.stringKeyParams["button-name"] as? String
                    expect(name).to(equal("sell-your-stuff"))
                }
                it("contains button position from which the event has been sent") {
                    let position = sut.params!.stringKeyParams["sell-button-position"] as? String
                    expect(position).to(equal("tabbar-camera"))
                }
                it("contains category id param") {
                    let name = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(name).to(equal(9))
                }
            }

            describe("listingSellError") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    product.name = "name"
                    product.descr = nil
                    product.category = .homeAndGarden
                    product.price = .normal(20)
                    product.images = MockFile.makeMocks(count: 2)
                    product.descr = String.makeRandom()
                    sut = TrackerEvent.listingSellError(.forbidden(cause: .differentCountry))
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-error"))
                }
                it("contains errorDescription") {
                    let errorDescription = sut.params!.stringKeyParams["error-description"] as? String
                    expect(errorDescription).to(equal("product-sell-different-country-error"))
                }
            }
            
            describe("listingSellComplete product") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    product.name = "name"
                    product.descr = nil
                    product.category = .homeAndGarden
                    product.price = .normal(20)
                    product.images = MockFile.makeMocks(count: 2)
                    product.descr = String.makeRandom()
                    sut = TrackerEvent.listingSellComplete(Listing.product(product), buttonName: .done,
                                                           sellButtonPosition: .floatingButton, negotiable: .yes,
                                                           pictureSource: .gallery, freePostingModeAllowed: true)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-complete"))
                }
                it("contains free-posting") {
                    let freePostingParameter = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePostingParameter).to(equal("false"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
                it("contains category-id") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(4))
                }
                it("contains product-name") {
                    let data = sut.params!.stringKeyParams["product-name"] as? String
                    expect(data).to(equal("name"))
                }
                it("contains product-description") {
                    let data = sut.params!.stringKeyParams["product-description"] as? Bool
                    expect(data).to(equal(true))
                }
                it("contains number-photos-posting") {
                    let data = sut.params!.stringKeyParams["number-photos-posting"] as? Int
                    expect(data).to(equal(2))
                }
                it("contains button-name") {
                    let data = sut.params!.stringKeyParams["button-name"] as? String
                    expect(data).to(equal("done"))
                }
                it("contains sell-button-position") {
                    let data = sut.params!.stringKeyParams["sell-button-position"] as? String
                    expect(data).to(equal("big-button"))
                }
                it("contains negotiable-price") {
                    let data = sut.params!.stringKeyParams["negotiable-price"] as? String
                    expect(data).to(equal("yes"))
                }
                it("contains picture-source") {
                    let data = sut.params!.stringKeyParams["picture-source"] as? String
                    expect(data).to(equal("gallery"))
                }
                it("contains posting-type") {
                    let data = sut.params!.stringKeyParams["posting-type"] as? String
                    expect(data).to(equal("stuff"))
                }
                it("contains make") {
                    let data = sut.params!.stringKeyParams["product-make"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains model") {
                    let data = sut.params!.stringKeyParams["product-model"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains year") {
                    let data = sut.params!.stringKeyParams["product-year"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains property type") {
                    let data = sut.params!.stringKeyParams["property-type"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains deal type") {
                    let data = sut.params!.stringKeyParams["deal-type"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains bedrooms") {
                    let data = sut.params!.stringKeyParams["bedroom-number"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains bathrooms") {
                    let data = sut.params!.stringKeyParams["bathroom-number"] as? String
                    expect(data).to(equal("N/A"))
                }
            }
            
            describe("listingSellComplete car") {
                beforeEach {
                    var car = MockCar.makeMock()
                    car.objectId = "r4nd0m1D"
                    car.name = "name"
                    car.descr = nil
                    car.category = .cars
                    car.price = .normal(20)
                    car.images = MockFile.makeMocks(count: 2)
                    car.descr = String.makeRandom()
                    car.carAttributes = CarAttributes(makeId: "makeId", make: "make", modelId: "modelId", model: "model", year: 1234)
                    sut = TrackerEvent.listingSellComplete(Listing.car(car), buttonName: .done,
                                                           sellButtonPosition: .floatingButton, negotiable: .yes,
                                                           pictureSource: .gallery, freePostingModeAllowed: true)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-complete"))
                }
                it("contains free-posting") {
                    let freePostingParameter = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePostingParameter).to(equal("false"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
                it("contains category-id") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(9))
                }
                it("contains product-name") {
                    let data = sut.params!.stringKeyParams["product-name"] as? String
                    expect(data).to(equal("name"))
                }
                it("contains product-description") {
                    let data = sut.params!.stringKeyParams["product-description"] as? Bool
                    expect(data).to(equal(true))
                }
                it("contains number-photos-posting") {
                    let data = sut.params!.stringKeyParams["number-photos-posting"] as? Int
                    expect(data).to(equal(2))
                }
                it("contains button-name") {
                    let data = sut.params!.stringKeyParams["button-name"] as? String
                    expect(data).to(equal("done"))
                }
                it("contains sell-button-position") {
                    let data = sut.params!.stringKeyParams["sell-button-position"] as? String
                    expect(data).to(equal("big-button"))
                }
                it("contains negotiable-price") {
                    let data = sut.params!.stringKeyParams["negotiable-price"] as? String
                    expect(data).to(equal("yes"))
                }
                it("contains picture-source") {
                    let data = sut.params!.stringKeyParams["picture-source"] as? String
                    expect(data).to(equal("gallery"))
                }
                it("contains sell-button-position") {
                    let data = sut.params!.stringKeyParams["sell-button-position"] as? String
                    expect(data).to(equal("big-button"))
                }
                it("contains negotiable-price") {
                    let data = sut.params!.stringKeyParams["negotiable-price"] as? String
                    expect(data).to(equal("yes"))
                }
                it("contains picture-source") {
                    let data = sut.params!.stringKeyParams["picture-source"] as? String
                    expect(data).to(equal("gallery"))
                }
                it("contains posting-type") {
                    let data = sut.params!.stringKeyParams["posting-type"] as? String
                    expect(data).to(equal("car"))
                }
                it("contains make") {
                    let data = sut.params!.stringKeyParams["product-make"] as? String
                    expect(data).to(equal("make"))
                }
                it("contains model") {
                    let data = sut.params!.stringKeyParams["product-model"] as? String
                    expect(data).to(equal("model"))
                }
                it("contains year") {
                    let data = sut.params!.stringKeyParams["product-year"] as? String
                    expect(data).to(equal("1234"))
                }
                it("contains property type") {
                    let data = sut.params!.stringKeyParams["property-type"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains deal type") {
                    let data = sut.params!.stringKeyParams["deal-type"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains bedrooms") {
                    let data = sut.params!.stringKeyParams["bedroom-number"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains bathrooms") {
                    let data = sut.params!.stringKeyParams["bathroom-number"] as? String
                    expect(data).to(equal("N/A"))
                }
            }
            
            describe("listingSellComplete real estate") {
                beforeEach {
                    var realEstate = MockRealEstate.makeMock()
                    realEstate.objectId = "r4nd0m1D"
                    realEstate.name = "name"
                    realEstate.descr = nil
                    realEstate.category = .homeAndGarden
                    realEstate.price = .normal(20)
                    realEstate.images = MockFile.makeMocks(count: 2)
                    realEstate.descr = String.makeRandom()
                    realEstate.realEstateAttributes = RealEstateAttributes(propertyType: .room,
                                                                           offerType: .rent,
                                                                           bedrooms: nil,
                                                                           bathrooms: 3.0,
                                                                           livingRooms: nil,
                                                                           sizeSquareMeters: nil)
                    sut = TrackerEvent.listingSellComplete(Listing.realEstate(realEstate), buttonName: .done,
                                                           sellButtonPosition: .floatingButton, negotiable: .yes,
                                                           pictureSource: .gallery, freePostingModeAllowed: true)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-complete"))
                }
                it("contains free-posting") {
                    let freePostingParameter = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePostingParameter).to(equal("false"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
                it("contains category-id") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(4))
                }
                it("contains product-name") {
                    let data = sut.params!.stringKeyParams["product-name"] as? String
                    expect(data).to(equal("name"))
                }
                it("contains product-description") {
                    let data = sut.params!.stringKeyParams["product-description"] as? Bool
                    expect(data).to(equal(true))
                }
                it("contains number-photos-posting") {
                    let data = sut.params!.stringKeyParams["number-photos-posting"] as? Int
                    expect(data).to(equal(2))
                }
                it("contains button-name") {
                    let data = sut.params!.stringKeyParams["button-name"] as? String
                    expect(data).to(equal("done"))
                }
                it("contains sell-button-position") {
                    let data = sut.params!.stringKeyParams["sell-button-position"] as? String
                    expect(data).to(equal("big-button"))
                }
                it("contains negotiable-price") {
                    let data = sut.params!.stringKeyParams["negotiable-price"] as? String
                    expect(data).to(equal("yes"))
                }
                it("contains picture-source") {
                    let data = sut.params!.stringKeyParams["picture-source"] as? String
                    expect(data).to(equal("gallery"))
                }
                it("contains posting-type") {
                    let data = sut.params!.stringKeyParams["posting-type"] as? String
                    expect(data).to(equal("real-estate"))
                }
                it("contains make") {
                    let data = sut.params!.stringKeyParams["product-make"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains model") {
                    let data = sut.params!.stringKeyParams["product-model"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains year") {
                    let data = sut.params!.stringKeyParams["product-year"] as? String
                    expect(data).to(equal("N/A"))
                }
                it("contains property type") {
                    let data = sut.params!.stringKeyParams["property-type"] as? String
                    expect(data).to(equal("room"))
                }
                it("contains deal type") {
                    let data = sut.params!.stringKeyParams["deal-type"] as? String
                    expect(data).to(equal("rent"))
                }
                it("contains bedrooms") {
                    let data = sut.params!.stringKeyParams["bedroom-number"] as? String
                    expect(data).to(equal("skip"))
                }
                it("contains bathrooms") {
                    let data = sut.params!.stringKeyParams["bathroom-number"] as? String
                    expect(data).to(equal("3.0"))
                }
            }

            describe("listingSellConfirmation") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmation(Listing.product(product))
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("listingSellConfirmationPost") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmationPost(Listing.product(product), buttonType: .button)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-post"))
                }
                it("contains button-type") {
                    let parameter = sut.params!.stringKeyParams["button-type"] as? String
                    expect(parameter).to(equal("button"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("listingSellConfirmationEdit") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmationEdit(Listing.product(product))
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-edit"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("listingSellConfirmationClose") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmationClose(Listing.product(product))
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-close"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("listingSellConfirmationShare") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmationShare(Listing.product(product), network: .facebook)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-share"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
                it("contains share-network") {
                    let data = sut.params!.stringKeyParams["share-network"] as? String
                    expect(data).to(equal("facebook"))
                }
            }

            describe("listingSellConfirmationShareCancel") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmationShareCancel(Listing.product(product), network: .facebook)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-share-cancel"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
                it("contains share-network") {
                    let data = sut.params!.stringKeyParams["share-network"] as? String
                    expect(data).to(equal("facebook"))
                }
            }

            describe("listingSellConfirmationShareComplete") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.listingSellConfirmationShareComplete(Listing.product(product), network: .facebook)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-share-complete"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
                it("contains share-network") {
                    let data = sut.params!.stringKeyParams["share-network"] as? String
                    expect(data).to(equal("facebook"))
                }
            }

            describe("listingEditStart") {
                it("has its event name") {
                    let user = MockUser.makeMock()
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingEditStart(user, listing: .product(product))
                    expect(sut.name.rawValue).to(equal("product-edit-start"))
                }
                it("contains the product id") {
                    var product = MockProduct.makeMock()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.listingEditStart(nil, listing: .product(product))
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("listingEditFormValidationFailed") {
                it("has its event name") {
                    _ = MockUser.makeMock()
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingEditFormValidationFailed(nil, listing: .product(product), description: "whatever")
                    expect(sut.name.rawValue).to(equal("product-edit-form-validation-failed"))
                }
                it("contains the description related params") {
                    let product = MockProduct.makeMock()
                    
                    sut = TrackerEvent.listingEditFormValidationFailed(nil, listing: .product(product), description: "whatever")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["description"] as? String
                    expect(description).to(equal("whatever"))
                }
                it("contains the product id") {
                    var product = MockProduct.makeMock()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.listingEditFormValidationFailed(nil, listing: .product(product), description: "whatever")
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("listingEditSharedFB") {
                it("has its event name") {
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingEditSharedFB(nil, listing: .product(product))
                    expect(sut.name.rawValue).to(equal("product-edit-shared-fb"))
                }
                it("contains the product id") {
                    var product = MockProduct.makeMock()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.listingEditSharedFB(nil, listing: .product(product))
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("listingEditComplete") {
                context("edit product") {
                    beforeEach {
                        var product = MockProduct.makeMock()
                        product.objectId = "r4nd0m1D"
                        product.name = "name"
                        product.descr = nil
                        product.category = .motorsAndAccessories
                        product.price = .normal(20)
                        product.images = MockFile.makeMocks(count: 2)
                        product.descr = String.makeRandom()
                        sut = TrackerEvent.listingEditComplete(nil, listing: .product(product), category: .homeAndGarden, editedFields: [.title, .category])
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("product-edit-complete"))
                    }
                    it("contains the product related params when passing by a product, name & category") {
                        expect(sut.params).notTo(beNil())
                    }
                    it ("contains category-id parameter") {
                        expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                        let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                        expect(categoryId).to(equal(4))
                    }
                    it ("containts product-id") {
                        expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                        let productId = sut.params!.stringKeyParams["product-id"] as? String
                        expect(productId).to(equal("r4nd0m1D"))
                    }
                    it ("containts product-id") {
                        expect(sut.params!.stringKeyParams["edited-fields"]).notTo(beNil())
                        let editedFields = sut.params!.stringKeyParams["edited-fields"] as? String
                        expect(editedFields).to(equal("title,category"))
                    }
                    it("contains property type") {
                        let data = sut.params!.stringKeyParams["property-type"] as? String
                        expect(data).to(equal("N/A"))
                    }
                    it("contains deal type") {
                        let data = sut.params!.stringKeyParams["deal-type"] as? String
                        expect(data).to(equal("N/A"))
                    }
                    it("contains bedrooms") {
                        let data = sut.params!.stringKeyParams["bedroom-number"] as? String
                        expect(data).to(equal("N/A"))
                    }
                    it("contains bathrooms") {
                        let data = sut.params!.stringKeyParams["bathroom-number"] as? String
                        expect(data).to(equal("N/A"))
                    }
                }
            }
            
            describe("listingEditComplete") {
                context("edit real estate") {
                    beforeEach {
                        var realEstate = MockRealEstate.makeMock()
                        realEstate.objectId = "r4nd0m1D"
                        realEstate.name = "name"
                        realEstate.descr = nil
                        realEstate.price = .normal(20)
                        realEstate.images = MockFile.makeMocks(count: 2)
                        realEstate.descr = String.makeRandom()
                        let realEstateAttributes = RealEstateAttributes(propertyType: .room,
                                                                        offerType: .rent,
                                                                        bedrooms: 3,
                                                                        bathrooms: 1.0,
                                                                        livingRooms: nil,
                                                                        sizeSquareMeters: nil)
                        realEstate.realEstateAttributes = realEstateAttributes
                        sut = TrackerEvent.listingEditComplete(nil, listing: .realEstate(realEstate), category: nil, editedFields: [.title, .category])
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("product-edit-complete"))
                    }
                    it("contains the product related params when passing by a product, name & category") {
                        expect(sut.params).notTo(beNil())
                    }
                    it ("contains category-id parameter") {
                        expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                        let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                        expect(categoryId).notTo(beNil())
                    }
                    it ("containts product-id") {
                        expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                        let productId = sut.params!.stringKeyParams["product-id"] as? String
                        expect(productId).to(equal("r4nd0m1D"))
                    }
                    it ("containts edited-fields") {
                        expect(sut.params!.stringKeyParams["edited-fields"]).notTo(beNil())
                        let editedFields = sut.params!.stringKeyParams["edited-fields"] as? String
                        expect(editedFields).to(equal("title,category"))
                    }
                    it("contains property type") {
                        let data = sut.params!.stringKeyParams["property-type"] as? String
                        expect(data).to(equal("room"))
                    }
                    it("contains deal type") {
                        let data = sut.params!.stringKeyParams["deal-type"] as? String
                        expect(data).to(equal("rent"))
                    }
                    it("contains bedrooms") {
                        let data = sut.params!.stringKeyParams["bedroom-number"] as? String
                        expect(data).to(equal("3"))
                    }
                    it("contains bathrooms") {
                        let data = sut.params!.stringKeyParams["bathroom-number"] as? String
                        expect(data).to(equal("1.0"))
                    }
                }
            }
            
            describe("listingDeleteStart") {
                it("has its event name") {
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingDeleteStart(.product(product))
                    expect(sut.name.rawValue).to(equal("product-delete-start"))
                }
                it("contains the product id") {
                    var product = MockProduct.makeMock()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.listingDeleteStart(.product(product))
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("listingDeleteComplete") {
                it("has its event name") {
                    let product = MockProduct.makeMock()
                    sut = TrackerEvent.listingDeleteComplete(.product(product))
                    expect(sut.name.rawValue).to(equal("product-delete-complete"))
                }
                it("contains the product id") {
                    var product = MockProduct.makeMock()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.listingDeleteComplete(.product(product))
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("relatedListings") {
                beforeEach {
                    sut = TrackerEvent.relatedListings(listingId: "12345",
                                                       source: .notFound)
                }
                
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("related-items-list"))
                }
                it("has product-id param") {
                    let productId = sut.params?.stringKeyParams["product-id"] as? String
                    expect(productId) == "12345"
                }
                it("has related-source param") {
                    let source = sut.params?.stringKeyParams["related-source"] as? String
                    expect(source) == "product-not-found"
                }
            }

            describe("phoneNumberRequest") {
                beforeEach {
                    sut = TrackerEvent.phoneNumberRequest(typePage: .chat)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("phone-number-request"))
                }
                it("has type-page param") {
                    let typePage = sut.params?.stringKeyParams["type-page"] as? String
                    expect(typePage) == "chat"
                }
            }

            describe("phoneNumberSent") {
                beforeEach {
                    sut = TrackerEvent.phoneNumberSent(typePage: .listingDetail)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("phone-number-sent"))
                }
                it("has type-page param") {
                    let typePage = sut.params?.stringKeyParams["type-page"] as? String
                    expect(typePage) == "product-detail"
                }
            }

            describe("phoneNumberNotNow") {
                beforeEach {
                    sut = TrackerEvent.phoneNumberNotNow(typePage: .chat)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("phone-number-not-now"))
                }
                it("has type-page param") {
                    let typePage = sut.params?.stringKeyParams["type-page"] as? String
                    expect(typePage) == "chat"
                }
            }
            
            describe("userMessageSent") {
                var userListing: MockUserListing!
                var product: MockProduct!
                var sendMessageInfo: SendMessageTrackingInfo!
                beforeEach {
                    userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false

                    product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)

                    sendMessageInfo = SendMessageTrackingInfo()
                        .set(listing: .product(product), freePostingModeAllowed: true)
                        .set(messageType: .text)
                        .set(quickAnswerType: nil)
                        .set(typePage: .chat)
                        .set(sellerRating: 4)
                        .set(isBumpedUp: .trueParameter)
                    sut = TrackerEvent.userMessageSent(info: sendMessageInfo)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("user-sent-message"))
                }
                it("has product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "AAAAA"
                }
                it("has product-price param") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice) == 123.983
                }
                it("has product-currency param") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency) == "EUR"
                }
                it("has category-id param") {
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory) == ListingCategory.homeAndGarden.rawValue
                }
                it("has coordinates params") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat) == 3.12354534

                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng) == 7.23983292
                }
                it("has item-type param") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("has user-to-id param") {
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId) == "56897"
                }
                it("has type-page param") {
                    let pageType = sut.params!.stringKeyParams["type-page"] as? String
                    expect(pageType) == "chat"
                }
                it("has free-posting param") {
                    let freePosting = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePosting) == "false"
                }
                describe("text message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .text)
                        sut = TrackerEvent.userMessageSent(info: sendMessageInfo)
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "text"
                    }
                    it("has quick-answer param with value false") {
                        let value = sut.params!.stringKeyParams["quick-answer"] as? String
                        expect(value) == "false"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                }
                describe("sticker message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .sticker)
                        sut = TrackerEvent.userMessageSent(info: sendMessageInfo)
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "sticker"
                    }
                    it("has quick-answer param with value false") {
                        let value = sut.params!.stringKeyParams["quick-answer"] as? String
                        expect(value) == "false"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                }
                describe("quick answer message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .quickAnswer)
                        sendMessageInfo.set(quickAnswerType: .notInterested)
                        sut = TrackerEvent.userMessageSent(info: sendMessageInfo)
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "quick-answer"
                    }
                    it("has quick-answer param with value false") {
                        let value = sut.params!.stringKeyParams["quick-answer"] as? String
                        expect(value) == "true"
                    }
                    it("has no quick-answer-type") {
                        let value = sut.params!.stringKeyParams["quick-answer-type"] as? String
                        expect(value) == "not-interested"
                    }
                }
            }

            describe("userMessageSentError") {
                var userListing: MockUserListing!
                var product: MockProduct!
                var sendMessageInfo: SendMessageTrackingInfo!
                beforeEach {
                    userListing = MockUserListing.makeMock()
                    userListing.objectId = "56897"
                    userListing.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                                                              state: "", countryCode: "NL", country: nil)
                    userListing.isDummy = false

                    product = MockProduct.makeMock()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .normal(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = userListing
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                                                          countryCode: "US", country: nil)

                    let error: EventParameterChatError = .serverError(code: 404)

                    sendMessageInfo = SendMessageTrackingInfo()
                        .set(listing: .product(product), freePostingModeAllowed: true)
                        .set(messageType: .text)
                        .set(quickAnswerType: nil)
                        .set(typePage: .chat)
                        .set(sellerRating: 4)
                        .set(isBumpedUp: .trueParameter)
                        .set(error: error)
                    sut = TrackerEvent.userMessageSentError(info: sendMessageInfo)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("user-sent-message-error"))
                }
                it("has product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "AAAAA"
                }
                it("has product-price param") {
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice) == 123.983
                }
                it("has product-currency param") {
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency) == "EUR"
                }
                it("has category-id param") {
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory) == ListingCategory.homeAndGarden.rawValue
                }
                it("has coordinates params") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat) == 3.12354534

                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng) == 7.23983292
                }
                it("has item-type param") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("has user-to-id param") {
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId) == "56897"
                }
                it("has type-page param") {
                    let pageType = sut.params!.stringKeyParams["type-page"] as? String
                    expect(pageType) == "chat"
                }
                it("has free-posting param") {
                    let freePosting = sut.params!.stringKeyParams["free-posting"] as? String
                    expect(freePosting) == "false"
                }
                it("has error-description param") {
                    let value = sut.params!.stringKeyParams["error-description"] as? String
                    expect(value) == "chat-server"
                }
                it("has error-details param") {
                    let value = sut.params!.stringKeyParams["error-details"] as? String
                    expect(value) == "404"
                }
                describe("text message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .text)
                        sut = TrackerEvent.userMessageSentError(info: sendMessageInfo)
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "text"
                    }
                    it("has quick-answer param with value false") {
                        let value = sut.params!.stringKeyParams["quick-answer"] as? String
                        expect(value) == "false"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                }
                describe("sticker message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .sticker)
                        sut = TrackerEvent.userMessageSentError(info: sendMessageInfo)
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "sticker"
                    }
                    it("has quick-answer param with value false") {
                        let value = sut.params!.stringKeyParams["quick-answer"] as? String
                        expect(value) == "false"
                    }
                    it("has no quick-answer-type") {
                        expect(sut.params!.stringKeyParams["quick-answer-type"]).to(beNil())
                    }
                }
                describe("quick answer message") {
                    beforeEach {
                        sendMessageInfo.set(messageType: .quickAnswer)
                        sendMessageInfo.set(quickAnswerType: .notInterested)
                        sut = TrackerEvent.userMessageSentError(info: sendMessageInfo)
                    }
                    it("has message-type param with value text") {
                        let value = sut.params!.stringKeyParams["message-type"] as? String
                        expect(value) == "quick-answer"
                    }
                    it("has quick-answer param with value false") {
                        let value = sut.params!.stringKeyParams["quick-answer"] as? String
                        expect(value) == "true"
                    }
                    it("has no quick-answer-type") {
                        let value = sut.params!.stringKeyParams["quick-answer-type"] as? String
                        expect(value) == "not-interested"
                    }
                }
            }

            describe("chatRelatedItemsStart") {
                beforeEach {
                    sut = TrackerEvent.chatRelatedItemsStart(.unanswered48h)
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("chat-related-items-start"))
                }
                it("shownReason parameter matches") {
                    expect(sut.params?.stringKeyParams["shown-reason"] as? String) == "unanswered-48h"
                }
            }

            describe("chatRelatedItemsComplete") {
                beforeEach {
                    sut = TrackerEvent.chatRelatedItemsComplete(20, shownReason: .listingSold)
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("chat-related-items-complete"))
                }
                it("item-position parameter matches") {
                    expect(sut.params?.stringKeyParams["item-position"] as? Int) == 20
                }
                it("shownReason parameter matches") {
                    expect(sut.params?.stringKeyParams["shown-reason"] as? String) == "product-sold"
                }
            }

            describe("profileVisit") {
                context("profileVisit") {
                    beforeEach {
                        var user = MockUser.makeMock()
                        user.objectId = "12345"
                        sut = TrackerEvent.profileVisit(user, profileType: .publicParameter , typePage: .listingDetail, tab: .selling)
                    }
                    it("has its event name ") {
                        expect(sut.name.rawValue).to(equal("profile-visit"))
                    }
                    it("user-to-id parameter matches") {
                        expect(sut.params?.stringKeyParams["user-to-id"] as? String) == "12345"
                    }
                    it("type-page parameter matches") {
                        expect(sut.params?.stringKeyParams["type-page"] as? String) == "product-detail"
                    }
                    it("tab parameter matches") {
                        expect(sut.params?.stringKeyParams["tab"] as? String) == "selling"
                    }
                    it("profile-type parameter matches") {
                        expect(sut.params?.stringKeyParams["profile-type"] as? String) == "public"
                    }
                }
            }

            describe("profileEditStart") {
                it("has its event name") {
                    sut = TrackerEvent.profileEditStart()
                    expect(sut.name.rawValue).to(equal("profile-edit-start"))
                }
            }
            
            describe("profileEditEditName") {
                it("has its event name") {
                    sut = TrackerEvent.profileEditEditName()
                    expect(sut.name.rawValue).to(equal("profile-edit-edit-name"))
                }
            }

            describe("profileEditEditLocationStart") {
                beforeEach {
                    sut = TrackerEvent.profileEditEditLocationStart()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-edit-edit-location-start"))
                }
            }
            
            describe("profileEditEditPicture") {
                it("has its event name") {
                    sut = TrackerEvent.profileEditEditPicture()
                    expect(sut.name.rawValue).to(equal("profile-edit-edit-picture"))
                }
            }

            describe("profileShareStart") {
                beforeEach {
                    sut = TrackerEvent.profileShareStart(.publicParameter)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-share-start"))
                }
                it("contains profile-type param") {
                    let typePage = sut.params!.stringKeyParams["profile-type"] as? String
                    expect(typePage).to(equal("public"))
                }
            }

            describe("profileShareComplete") {
                beforeEach {
                    sut = TrackerEvent.profileShareComplete(.publicParameter, shareNetwork: .facebook)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-share-complete"))
                }
                it("contains profile-type param") {
                    let typePage = sut.params!.stringKeyParams["profile-type"] as? String
                    expect(typePage).to(equal("public"))
                }
                it("contains share-network param") {
                    let typePage = sut.params!.stringKeyParams["share-network"] as? String
                    expect(typePage).to(equal("facebook"))
                }
            }
            
            describe("profileEditEmailStart") {
                beforeEach {
                    sut = TrackerEvent.profileEditEmailStart(withUserId: "1234")
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-edit-email-start"))
                }
                it("contains user-id param") {
                    let param = sut.params!.stringKeyParams["user-id"] as? String
                    expect(param) == "1234"
                }
            }
            
            describe("profileEditEmailComplete") {
                beforeEach {
                    sut = TrackerEvent.profileEditEmailComplete(withUserId: "1234")
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-edit-email-complete"))
                }
                it("contains user-id param") {
                    let param = sut.params!.stringKeyParams["user-id"] as? String
                    expect(param) == "1234"
                }
            }

            describe("appInviteFriendStart") {
                beforeEach {
                    sut = TrackerEvent.appInviteFriendStart(.settings)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-invite-friend-start"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("settings"))
                }
            }

            describe("appInviteFriend") {
                beforeEach {
                    sut = TrackerEvent.appInviteFriend(.facebook, typePage: .settings)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-invite-friend"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the network where the content has been shared") {
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("settings"))
                }
            }

            describe("App invite friend don't show again") {
                beforeEach {
                    sut = TrackerEvent.appInviteFriendDontAsk(.settings)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-invite-friend-dont-ask"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("settings"))
                }
            }

            describe("facebook friend invite Cancel") {
                beforeEach {
                    sut = TrackerEvent.appInviteFriendCancel(.facebook, typePage: .settings)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-invite-friend-cancel"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the network where the content has been shared") {
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("settings"))
                }
            }
            
            describe("facebook friend invite complete") {
                beforeEach {
                    sut = TrackerEvent.appInviteFriendComplete(.facebook, typePage: .settings)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-invite-friend-complete"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the network where the content has been shared") {
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("settings"))
                }
            }

            describe("permissionAlertStart") {
                it("has its event name") {
                    sut = TrackerEvent.permissionAlertStart(.push, typePage: .listingList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.name.rawValue).to(equal("permission-alert-start"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertStart(.push, typePage: .listingList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.listingList.rawValue))

                    expect(sut.params!.stringKeyParams["alert-type"]).notTo(beNil())
                    let alertType = sut.params!.stringKeyParams["alert-type"] as? String
                    expect(alertType).to(equal(EventParameterPermissionAlertType.custom.rawValue))
                }
            }

            describe("permissionAlertComplete") {
                it("has its event name") {
                    sut = TrackerEvent.permissionAlertComplete(.push, typePage: .listingList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.name.rawValue).to(equal("permission-alert-complete"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertComplete(.push, typePage: .listingList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.listingList.rawValue))

                    expect(sut.params!.stringKeyParams["alert-type"]).notTo(beNil())
                    let alertType = sut.params!.stringKeyParams["alert-type"] as? String
                    expect(alertType).to(equal(EventParameterPermissionAlertType.custom.rawValue))
                }
            }

            describe("permissionAlertCancel") {
                it("has its event name") {
                    sut = TrackerEvent.permissionSystemCancel(.push, typePage: .listingList)
                    expect(sut.name.rawValue).to(equal("permission-system-cancel"))
                }
                it("contains the permission related params when passing by a permission type & page") {
                    sut = TrackerEvent.permissionSystemCancel(.push, typePage: .listingList)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.listingList.rawValue))
                }
            }

            describe("permissionSystemComplete") {
                it("has its event name") {
                    sut = TrackerEvent.permissionSystemComplete(.push, typePage: .listingList)
                    expect(sut.name.rawValue).to(equal("permission-system-complete"))
                }
                it("contains the permission related params when passing by a permission type & page") {
                    sut = TrackerEvent.permissionSystemComplete(.push, typePage: .listingList)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.listingList.rawValue))
                }
            }

            describe("userReport") {
                beforeEach {
                    user = MockUser.makeMock()
                    user.objectId = "test-id"
                    sut = TrackerEvent.profileReport(.profile, reportedUserId: user.objectId!, reason: .scammer)
                }
                afterEach {
                    user = nil
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-report"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("profile"))
                }
                it("contains the user reported id") {
                    let userId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userId).to(equal(user.objectId))
                }
                it("contains the user report reason") {
                    let network = sut.params!.stringKeyParams["report-reason"] as? String
                    expect(network).to(equal("scammer"))
                }
            }

            describe("userBlock") {
                beforeEach {
                    let userId1 = "test-id-1"
                    let userId2 = "test-id-2"
                    sut = TrackerEvent.profileBlock(.profile, blockedUsersIds: [userId1, userId2], buttonPosition: .threeDots)
                }
                afterEach {
                    user = nil
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-block"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("profile"))
                }
                it("contains the blocked users ids separated by commas") {
                    let userId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userId).to(equal("test-id-1,test-id-2"))
                }
                it("contains the button position parameter") {
                    let buttomPosition = sut.params!.stringKeyParams["block-button-position"] as? String
                    expect(buttomPosition).to(equal("three-dots"))
                }
            }

            describe("userUnblock") {
                beforeEach {
                    let userId1 = "test-id-1"
                    let userId2 = "test-id-2"
                    sut = TrackerEvent.profileUnblock(.profile, unblockedUsersIds: [userId1, userId2])
                }
                afterEach {
                    user = nil
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("profile-unblock"))
                }
                it("Contains params") {
                    expect(sut.params).notTo(beNil())
                }
                it("contains the page from which the event has been sent") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal("profile"))
                }
                it("contains the blocked users ids separated by commas") {
                    let userId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userId).to(equal("test-id-1,test-id-2"))
                }
            }

            describe("user rating start") {
                beforeEach {
                    sut = TrackerEvent.userRatingStart("12345", typePage: .chat)
                }
                it("has its event name") {
                    expect(sut.name.rawValue) == "user-rating-start"
                }
                it("contains type-page param") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage) == "chat"
                }
                it("contains user-to-id param") {
                    let userToId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == "12345"
                }
            }

            describe("user rating complete") {
                beforeEach {
                    sut = TrackerEvent.userRatingComplete("12345", typePage: .chat, rating: 4, hasComments: true)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("user-rating-complete"))
                }
                it("contains type-page param") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage) == "chat"
                }
                it("contains user-to-id param") {
                    let userToId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == "12345"
                }
                it("contains rating-stars param") {
                    let ratingStars = sut.params!.stringKeyParams["rating-stars"] as? Int
                    expect(ratingStars) == 4
                }
                it("contains rating-comments param") {
                    let ratingComments = sut.params!.stringKeyParams["rating-comments"] as? Bool
                    expect(ratingComments) == true
                }
            }

            describe("open app external") {
                context("has info for all the params") {
                    beforeEach {
                        sut = TrackerEvent.openAppExternal("ut_campaign", medium: "ut_medium", source: .external(source: "ut_source"))
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("open-app-external"))
                    }
                    it("contains campaign param") {
                        let campaign = sut.params!.stringKeyParams["campaign"] as? String
                        expect(campaign) == "ut_campaign"
                    }
                    it("contains medium param") {
                        let medium = sut.params!.stringKeyParams["medium"] as? String
                        expect(medium) == "ut_medium"
                    }
                    it("contains source param") {
                        let source = sut.params!.stringKeyParams["source"] as? String
                        expect(source) == "ut_source"
                    }
                }
                context("params with no info") {
                    beforeEach {
                        sut = TrackerEvent.openAppExternal(nil, medium: nil, source: .none)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("open-app-external"))
                    }
                    it("does not contain campaign param") {
                        let campaign = sut.params!.stringKeyParams["campaign"] as? String
                        expect(campaign).to(beNil())
                    }
                    it("does not contain medium param") {
                        let medium = sut.params!.stringKeyParams["medium"] as? String
                        expect(medium).to(beNil())
                    }
                    it("does not contain source param") {
                        let source = sut.params!.stringKeyParams["source"] as? String
                        expect(source).to(beNil())
                    }
                }
            }
            describe("express chat") {
                context("express chat start") {
                    beforeEach {
                        sut = TrackerEvent.expressChatStart(.automatic)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "express-chat-start"
                    }
                    it("has its trigger") {
                        let trigger = sut.params!.stringKeyParams["express-chat-trigger"] as? String
                        expect(trigger) == "automatic"
                    }
                }

                context("express chat complete") {
                    beforeEach {
                        sut = TrackerEvent.expressChatComplete(3, trigger: .automatic)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "express-chat-complete"
                    }
                    it("contains type-page param") {
                        let expressConversations = sut.params!.stringKeyParams["express-conversations"] as? Int
                        expect(expressConversations) == 3
                    }
                    it("has its trigger") {
                        let trigger = sut.params!.stringKeyParams["express-chat-trigger"] as? String
                        expect(trigger) == "automatic"
                    }
                }

                context("express chat don't ask again") {
                    beforeEach {
                        sut = TrackerEvent.expressChatDontAsk(.automatic)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "express-chat-dont-ask"
                    }
                    it("has its trigger") {
                        let trigger = sut.params!.stringKeyParams["express-chat-trigger"] as? String
                        expect(trigger) == "automatic"
                    }
                }
            }
            
            describe("NPS Survey") {
                context("NPS Start") {
                    beforeEach {
                        sut = TrackerEvent.npsStart()
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "nps-start"
                    }
                }
                
                context("NPS Complete") {
                    beforeEach {
                        sut = TrackerEvent.npsComplete(2)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "nps-complete"
                    }
                    it("contains score param") {
                        let score = sut.params!.stringKeyParams["nps-score"] as? Int
                        expect(score) == 2
                    }
                }
            }

            describe("Web Survey") {
                context("Survey start") {
                    beforeEach {
                        sut = TrackerEvent.surveyStart(userId: "my-user-id", surveyUrl: "https://www.thesurvey.com")
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "survey-start"
                    }
                    it("contains userId param") {
                        let param = sut.params!.stringKeyParams["user-id"] as? String
                        expect(param) == "my-user-id"
                    }
                    it("contains surveyUrl param") {
                        let param = sut.params!.stringKeyParams["survey-url"] as? String
                        expect(param) == "https://www.thesurvey.com"
                    }
                }

                context("Survey completed") {
                    beforeEach {
                        sut = TrackerEvent.surveyCompleted(userId: "my-user-id", surveyUrl: "https://www.thesurvey.com")
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "survey-completed"
                    }
                    it("contains userId param") {
                        let param = sut.params!.stringKeyParams["user-id"] as? String
                        expect(param) == "my-user-id"
                    }
                    it("contains surveyUrl param") {
                        let param = sut.params!.stringKeyParams["survey-url"] as? String
                        expect(param) == "https://www.thesurvey.com"
                    }
                }
            }

            describe("Verify Account") {
                context("Verify Account Start") {
                    beforeEach {
                        sut = TrackerEvent.verifyAccountStart(.chat)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "verify-account-start"
                    }
                    it("contains type-page param") {
                        let param = sut.params!.stringKeyParams["type-page"] as? String
                        expect(param) == "chat"
                    }
                }

                context("Verify Account Complete") {
                    beforeEach {
                        sut = TrackerEvent.verifyAccountComplete(.chat, network: .facebook)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "verify-account-complete"
                    }
                    it("contains type-page param") {
                        let param = sut.params!.stringKeyParams["type-page"] as? String
                        expect(param) == "chat"
                    }
                    it("contains account-network param") {
                        let param = sut.params!.stringKeyParams["account-network"] as? String
                        expect(param) == "facebook"
                    }
                }
            }
            describe("In app chat notification start") {
                beforeEach {
                    sut = TrackerEvent.inappChatNotificationStart()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("in-app-chat-notification-start"))
                }
            }
            describe("In app chat notification complete") {
                beforeEach {
                    sut = TrackerEvent.inappChatNotificationComplete()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("in-app-chat-notification-complete"))
                }
            }
            describe("Signup captcha") {
                beforeEach {
                    sut = TrackerEvent.signupCaptcha()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("signup-captcha"))
                }
            }
            describe("Notification center start") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterStart()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-start"))
                }
            }
            describe("Notification center complete type modular") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(source: .cta1, cardAction: "profile-visit", notificationCampaign: "inactive_march_2017")
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains click-area param") {
                    let param = sut.params!.stringKeyParams["notification-click-area"] as? String
                    expect(param) == "cta-1"
                }
                it("contains action param") {
                    let param = sut.params!.stringKeyParams["notification-action"] as? String
                    expect(param) == "profile-visit"
                }
                it("contains notificationCampaign param") {
                    let param = sut.params!.stringKeyParams["notification-campaign"] as? String
                    expect(param) == "inactive_march_2017"
                }
            }
            describe("Marketing Push Notifications") {
                beforeEach {
                    sut = TrackerEvent.marketingPushNotifications("123456", enabled: true)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("marketing-push-notifications"))
                }
                it("contains user-id param") {
                    let param = sut.params!.stringKeyParams["user-id"] as? String
                    expect(param) == "123456"
                }
                it("contains enabled param") {
                    let param = sut.params!.stringKeyParams["enabled"] as? Bool
                    expect(param) == true
                }
            }
            describe("bump banner show") {
                beforeEach {
                    sut = TrackerEvent.bumpBannerShow(type: .paid, listingId: "1122", storeProductId: "tier1")
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("bump-banner-show"))
                }
                it("type matches") {
                    expect(sut.params?.stringKeyParams["bump-type"] as? String) == "paid"
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "1122"
                }
                it("storeProductId matches") {
                    expect(sut.params?.stringKeyParams["store-productId"] as? String) == "tier1"
                }
            }
            describe("bump banner Info shown") {
                beforeEach {
                    sut = TrackerEvent.bumpBannerInfoShown(type: .paid, listingId: "1122", storeProductId: "tier1")
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("bump-info-shown"))
                }
                it("type matches") {
                    expect(sut.params?.stringKeyParams["bump-type"] as? String) == "paid"
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "1122"
                }
                it("storeProductId matches") {
                    expect(sut.params?.stringKeyParams["store-productId"] as? String) == "tier1"
                }
            }
            describe("bump up start") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "12345"
                    sut = TrackerEvent.listingBumpUpStart(.product(product), price: .free, type: .free,
                                                          storeProductId: nil, isPromotedBump: .falseParameter)
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("bump-up-start"))
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "12345"
                }
                it("price matches") {
                    expect(sut.params?.stringKeyParams["price"] as? String) == "free"
                }
                it("type matches") {
                    expect(sut.params?.stringKeyParams["bump-type"] as? String) == "free"
                }
                it("storeProductId is N/A") {
                    expect(sut.params?.stringKeyParams["store-productId"] as? String) == TrackerEvent.notApply
                }
                it("promotedBump param is false") {
                    expect(sut.params?.stringKeyParams["promoted-bump"] as? String) == "false"
                }
            }
            describe("bump up complete") {
                beforeEach {
                    var product = MockProduct.makeMock()
                    product.objectId = "12345"
                    sut = TrackerEvent.listingBumpUpComplete(.product(product), price: .free, type: .free, restoreRetriesCount: 8,
                                                             network: .facebook, transactionStatus: .purchasingPurchased,
                                                             storeProductId: nil, isPromotedBump: .falseParameter)
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("bump-up-complete"))
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "12345"
                }
                it("price matches") {
                    expect(sut.params?.stringKeyParams["price"] as? String) == "free"
                }
                it("type matches") {
                    expect(sut.params?.stringKeyParams["bump-type"] as? String) == "free"
                }
                it("retries number matches") {
                    expect(sut.params?.stringKeyParams["retries-number"] as? Int) == 8
                }
                it("network matches") {
                    expect(sut.params?.stringKeyParams["share-network"] as? String) == "facebook"
                }
                it("storeProductId is N/A") {
                    expect(sut.params?.stringKeyParams["store-productId"] as? String) == TrackerEvent.notApply
                }
                it("promotedBump param is false") {
                    expect(sut.params?.stringKeyParams["promoted-bump"] as? String) == "false"
                }
            }
            describe("bump up fail") {
                beforeEach {
                    sut = TrackerEvent.listingBumpUpFail(type: .paid,
                                                         listingId: "1122",
                                                         transactionStatus: .purchasingPurchased,
                                                         storeProductId: "tier2")
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("bump-up-fail"))
                }
                it("type matches") {
                    expect(sut.params?.stringKeyParams["bump-type"] as? String) == "paid"
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "1122"
                }
                it("transaction status matches") {
                    expect(sut.params?.stringKeyParams["transaction-status"] as? String) == "purchasing-purchased"
                }
                it("storeProductId matches") {
                    expect(sut.params?.stringKeyParams["store-productId"] as? String) == "tier2"
                }
            }
            describe("mobile payment complete") {
                beforeEach {
                    sut = TrackerEvent.mobilePaymentComplete(paymentId: "007", listingId: "1122", transactionStatus: .purchasingPurchased)
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("mobile-payment-complete"))
                }
                it("payment id matches") {
                    expect(sut.params?.stringKeyParams["payment-id"] as? String) == "007"
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "1122"
                }
                it("transaction status matches") {
                    expect(sut.params?.stringKeyParams["transaction-status"] as? String) == "purchasing-purchased"
                }
            }
            describe("mobile payment fail") {
                beforeEach {
                    sut = TrackerEvent.mobilePaymentFail(reason: nil, listingId: "1122", transactionStatus: .purchasingPurchased)
                }
                it("has its event name ") {
                    expect(sut.name.rawValue).to(equal("mobile-payment-fail"))
                }
                it("reason matches") {
                    expect(sut.params?.stringKeyParams["reason"] as? String) == ""
                }
                it("product id matches") {
                    expect(sut.params?.stringKeyParams["product-id"] as? String) == "1122"
                }
                it("transaction status matches") {
                    expect(sut.params?.stringKeyParams["transaction-status"] as? String) == "purchasing-purchased"
                }
            }
            describe("bump up not allowed") {
                beforeEach {
                    sut = TrackerEvent.bumpUpNotAllowed(.notAllowedInternal)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("bump-up-not-allowed"))
                }
                it("reason matches") {
                    expect(sut.params?.stringKeyParams["reason"] as? String) == "internal"
                }
            }
            describe("bump up not allowed contact us") {
                beforeEach {
                    sut = TrackerEvent.bumpUpNotAllowedContactUs(.notAllowedInternal)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("bump-up-not-allowed-contact-us"))
                }
                it("reason matches") {
                    expect(sut.params?.stringKeyParams["reason"] as? String) == "internal"
                }
            }
            describe("promote bump up shown") {
                beforeEach {
                    sut = TrackerEvent.bumpUpPromo()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("bump-up-promo"))
                }
            }
            describe("chat-window-open") {
                beforeEach {
                    sut = TrackerEvent.chatWindowVisit(.inAppNotification, chatEnabled: true)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("chat-window-open"))
                }
                it("contains typePage parameter") {
                    let param = sut.params!.stringKeyParams["type-page"] as? String
                    expect(param) == "in-app-notification"
                }
                it("contains chatEnabled parameter") {
                    let param = sut.params!.stringKeyParams["chat-enabled"] as? Bool
                    expect(param) == true
                }
            }
            describe("app rating start") {
                beforeEach {
                    sut = TrackerEvent.appRatingStart(EventParameterRatingSource.listingSellComplete)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-rating-start"))
                }
                it("contains rating source param") {
                    let param = sut.params!.stringKeyParams["app-rating-source"] as? String
                    expect(param).to(equal("product-sell-complete"))
                }
            }
            describe("app rating rate") {
                beforeEach {
                    sut = TrackerEvent.appRatingRate(reason: nil)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("app-rating-rate"))
                }
            }
            
            describe("empty state error") {
                beforeEach {
                    sut = TrackerEvent.emptyStateVisit(typePage: .chat, reason: .notFound, errorCode: 404)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("empty-state-error"))
                }
                it("contains typePage parameter") {
                    let param = sut.params!.stringKeyParams["type-page"] as? String
                    expect(param) == "chat"
                }
                it("contains reason parameter") {
                    let param = sut.params!.stringKeyParams["reason"] as? String
                    expect(param) == "not-found"
                }
                it("contains error details parameter") {
                    let param = sut.params!.stringKeyParams["error-details"] as? String
                    expect(param) == "404"
                }
            }
            describe("user rating report") {
                beforeEach {
                    sut = TrackerEvent.userRatingReport(userFromId: "abcde1234", ratingStars: 4)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("user-rating-report"))
                }
                it("contains userFromId parameter") {
                    let param = sut.params!.stringKeyParams["user-from-id"] as? String
                    expect(param) == "abcde1234"
                }
                it("contains rating-stars parameter") {
                    let param = sut.params!.stringKeyParams["rating-stars"] as? Int
                    expect(param).to(equal(4))
                }
            }
            describe("category header filter") {
                beforeEach {
                    sut = TrackerEvent.filterCategoryHeaderSelected(position: 1, name: "cars")
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("filter-bubble"))
                }
                it("contains bubble position parameter") {
                    let param = sut.params!.stringKeyParams["bubble-position"] as? Int
                    expect(param) == 1
                }
                it("contains bubble name parameter") {
                    let param = sut.params!.stringKeyParams["bubble-name"] as? String
                    expect(param) == "cars"
                }
            }
            describe("onboarding interests complete") {
                beforeEach {
                    sut = TrackerEvent.onboardingInterestsComplete(superKeywords: [2, 3])
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("onboarding-interests-complete"))
                }
                it("contains superkeyword-total parameter") {
                    let param = sut.params!.stringKeyParams["superkeyword-total"] as? Int
                    expect(param) == 2
                }
                it("contains superkeyword-ids parameter") {
                    let param = sut.params!.stringKeyParams["superkeyword-ids"] as? [Int]
                    expect(param) == [2, 3]
                }
            }
            describe("categories start") {
                beforeEach {
                    sut = TrackerEvent.categoriesStart(source: .filter)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("categories-start"))
                }
                it("contains type parameter") {
                    let param = sut.params!.stringKeyParams["type-page"] as? String
                    expect(param) == "filter"
                }
            }
            describe("categories complete") {
                beforeEach {
                    sut = TrackerEvent.categoriesComplete(keywordName: "electronics", source: .listingList)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("categories-complete"))
                }
                it("contains type parameter") {
                    let param = sut.params!.stringKeyParams["type-page"] as? String
                    expect(param) == "product-list"
                }
                it("contains keyword name parameter") {
                    let param = sut.params!.stringKeyParams["keyword-name"] as? String
                    expect(param) == "electronics"
                }
            }
            
            describe("product sell your stuff button") {
                beforeEach {
                    sut = TrackerEvent.listingSellYourStuffButton()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-your-stuff-button"))
                }
            }
            
            describe("open option on posting summary") {
                beforeEach {
                    sut = TrackerEvent.openOptionOnSummary(fieldOpen: .location, postingType: .realEstate)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("posting-summary-open"))
                }
                it("contains open field") {
                    let param = sut.params!.stringKeyParams["open-field"] as? String
                    expect(param) == "location"
                }
                it("contains posting type") {
                    let param = sut.params!.stringKeyParams["posting-type"] as? String
                    expect(param) == "real-estate"
                }
            }
            
            describe("chat delete complete") {
                beforeEach {
                    sut = TrackerEvent.chatDeleteComplete(numberOfConversations: 10, isInactiveConversation: false)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("chat-delete-complete"))
                }
                it("contains chats deleted") {
                    let param = sut.params!.stringKeyParams["chats-deleted"] as? Int
                    expect(param) == 10
                }
                it("contains inactive conversations boolean") {
                    let param = sut.params!.stringKeyParams["inactive-conversations"] as? Bool
                    expect(param) == false
                }
            }
            
            describe("chat view inactive conversations") {
                beforeEach {
                    sut = TrackerEvent.chatViewInactiveConversations()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("chat-view-inactive-conversations"))
                }
            }
            
            describe("chat inactive conversations shown") {
                beforeEach {
                    sut = TrackerEvent.chatInactiveConversationsShown()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("chat-inactive-conversations-shown"))
                }
            }
        }
    }
}
