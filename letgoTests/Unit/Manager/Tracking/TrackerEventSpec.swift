
import CoreLocation
@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class TrackerEventSpec: QuickSpec {
    
    override func spec() {
        var sut: TrackerEvent!
        var user: MockUser!
        
        fdescribe("factory methods") {
            describe("location") {
                it("has its event name") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .sensor)!
                    let locationServiceStatus: LocationServiceStatus = .disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    expect(sut.name.rawValue).to(equal("location"))
                }
                it("contains the location type when retrieving from sensors") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .sensor)!
                    let locationServiceStatus: LocationServiceStatus = .disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("sensor"))
                }
                it("contains the location type when setting manually") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .manual)!
                    let locationServiceStatus: LocationServiceStatus = .disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("manual"))
                }
                it("contains the location type when retrieving from ip lookup") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("iplookup"))
                }
                it("contains the location enabled false & location allowed false when location Disabled") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-enabled"]).notTo(beNil())
                    let locationEnabled = sut.params!.stringKeyParams["location-enabled"] as? Bool
                    expect(locationEnabled).to(beFalse())
                    expect(sut.params!.stringKeyParams["location-allowed"]).notTo(beNil())
                    let locationAllowed = sut.params!.stringKeyParams["location-allowed"] as? Bool
                    expect(locationAllowed).to(beFalse())
                }
                it("contains the location enabled true & location allowed false when location Enabled/NotDetermined") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .enabled(.notDetermined)
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-enabled"]).notTo(beNil())
                    let locationEnabled = sut.params!.stringKeyParams["location-enabled"] as? Bool
                    expect(locationEnabled).to(beTrue())
                    expect(sut.params!.stringKeyParams["location-allowed"]).notTo(beNil())
                    let locationAllowed = sut.params!.stringKeyParams["location-allowed"] as? Bool
                    expect(locationAllowed).to(beFalse())
                }
                it("contains the location enabled true & location allowed false when location Enabled/Restricted") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .enabled(.restricted)
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-enabled"]).notTo(beNil())
                    let locationEnabled = sut.params!.stringKeyParams["location-enabled"] as? Bool
                    expect(locationEnabled).to(beTrue())
                    expect(sut.params!.stringKeyParams["location-allowed"]).notTo(beNil())
                    let locationAllowed = sut.params!.stringKeyParams["location-allowed"] as? Bool
                    expect(locationAllowed).to(beFalse())
                }
                it("contains the location enabled true & location allowed false when location Enabled/Denied") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .enabled(.denied)
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-enabled"]).notTo(beNil())
                    let locationEnabled = sut.params!.stringKeyParams["location-enabled"] as? Bool
                    expect(locationEnabled).to(beTrue())
                    expect(sut.params!.stringKeyParams["location-allowed"]).notTo(beNil())
                    let locationAllowed = sut.params!.stringKeyParams["location-allowed"] as? Bool
                    expect(locationAllowed).to(beFalse())
                }
                it("contains the location enabled true & location allowed true when location Enabled/AuthorizedAlways") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .enabled(.authorized)
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-enabled"]).notTo(beNil())
                    let locationEnabled = sut.params!.stringKeyParams["location-enabled"] as? Bool
                    expect(locationEnabled).to(beTrue())
                    expect(sut.params!.stringKeyParams["location-allowed"]).notTo(beNil())
                    let locationAllowed = sut.params!.stringKeyParams["location-allowed"] as? Bool
                    expect(locationAllowed).to(beTrue())
                }
                it("contains the location enabled true & location allowed true when location Enabled/AuthorizedWhenInUse") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    let locationServiceStatus: LocationServiceStatus = .enabled(.authorized)
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-enabled"]).notTo(beNil())
                    let locationEnabled = sut.params!.stringKeyParams["location-enabled"] as? Bool
                    expect(locationEnabled).to(beTrue())
                    expect(sut.params!.stringKeyParams["location-allowed"]).notTo(beNil())
                    let locationAllowed = sut.params!.stringKeyParams["location-allowed"] as? Bool
                    expect(locationAllowed).to(beTrue())
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
                    sut = TrackerEvent.signupEmail(.sell, newsletter: .unset)
                    expect(sut.name.rawValue).to(equal("signup-email"))
                }
                it("contains the appropiate login source signing in via email from posting") {
                    sut = TrackerEvent.signupEmail(.sell, newsletter: .unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source signing in via email from chats") {
                    sut = TrackerEvent.signupEmail(.chats, newsletter: .unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source signing in via email from profile") {
                    sut = TrackerEvent.signupEmail(.profile, newsletter: .unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source signing in via email from mark as favourite") {
                    sut = TrackerEvent.signupEmail(.favourite, newsletter: .unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source signing in via email from mark as sold") {
                    sut = TrackerEvent.signupEmail(.markAsSold, newsletter: .unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source signing in via email from as a question") {
                    sut = TrackerEvent.signupEmail(.askQuestion, newsletter: .unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source signing in via email from report fraud") {
                    sut = TrackerEvent.signupEmail(.reportFraud, newsletter: .unset)
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
                    sut = TrackerEvent.loginBlockedAccountStart(.email)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-blocked-account-start"))
                }
                it("contains the Account network parameter") {
                    let network = sut.params!.stringKeyParams["account-network"] as! String
                    expect(network) == "email"
                }
            }

            describe("Login Blocked Account Contact us") {
                beforeEach {
                    sut = TrackerEvent.loginBlockedAccountContactUs(.email)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-blocked-account-contact-us"))
                }
                it("contains the Account network parameter") {
                    let network = sut.params!.stringKeyParams["account-network"] as! String
                    expect(network) == "email"
                }
            }

            describe("Login Blocked Account Keep browsing") {
                beforeEach {
                    sut = TrackerEvent.loginBlockedAccountKeepBrowsing(.email)
                }

                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("login-blocked-account-keep-browsing"))
                }
                it("contains the Account network parameter") {
                    let network = sut.params!.stringKeyParams["account-network"] as! String
                    expect(network) == "email"
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
            
            describe("productList") {
                it("has its event name") {
                    sut = TrackerEvent.productList(nil, categories: nil, searchQuery: nil)
                    expect(sut.name.rawValue).to(equal("product-list"))
                }
                it("contains the category related params when passing by a category") {
                    let categories: [ProductCategory] = [.homeAndGarden]
                    sut = TrackerEvent.productList(nil, categories: categories, searchQuery: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("4"))
                }
                it("contains the category related params when passing by several categories") {
                    let categories: [ProductCategory] = [.homeAndGarden, .fashionAndAccesories]
                    sut = TrackerEvent.productList(nil, categories: categories, searchQuery: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("4,6"))
                }
                it("contains the search query related params when passing by a search query") {
                    let searchQuery = "iPhone"
                    sut = TrackerEvent.productList(nil, categories: nil, searchQuery: searchQuery)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["search-keyword"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["search-keyword"] as? String
                    expect(categoryId).to(equal(searchQuery))
                }
            }

            describe("searchStart") {
                it("has its event name") {
                    sut = TrackerEvent.searchStart(nil)
                    expect(sut.name.rawValue).to(equal("search-start"))
                }
            }
            
            describe("searchComplete") {
                context("success"){
                    beforeEach {
                        sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .success, isLastSearch: true)
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
                        sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .fail, isLastSearch: true)
                    }
                    it("search si no success") {
                        let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                        expect(searchSuccess) == "no"
                    }
                }
            }

            describe("filterStart") {
                it("has its event name") {
                    sut = TrackerEvent.filterStart()
                    expect(sut.name.rawValue).to(equal("filter-start"))
                }
            }
            
            describe("filterComplete") {
                context("receiving all params") {
                    beforeEach {
                        let coords = LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123)
                        sut = TrackerEvent.filterComplete(coords, distanceRadius: 10, distanceUnit: DistanceType.km,
                            categories: [.electronics, .carsAndMotors],
                            sortBy: ProductSortCriteria.distance, postedWithin: ProductTimeCriteria.day,
                            priceRange: .priceRange(min: 5, max: 100), freePostingModeAllowed: true)
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
                }
                context("not receiving all params, contains the default params") {
                    beforeEach {
                        sut = TrackerEvent.filterComplete(nil, distanceRadius: nil, distanceUnit: DistanceType.km,
                            categories: nil, sortBy: nil, postedWithin: nil, priceRange: .priceRange(min: nil, max: nil), freePostingModeAllowed: false)
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
                        expect(sut.params!.stringKeyParams["free-posting"] as? String) == "N/A"
                    }
                }
            }
            
            describe("productDetailVisit") {
                beforeEach {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)

                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)

                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "Catalonia",
                        countryCode: "US", country: nil)

                    sut = TrackerEvent.productDetailVisit(product, visitUserAction: .none, source: .productList)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-visit"))
                }
                it("contains user action") {
                    let userAction = sut.params!.stringKeyParams["user-action"] as? String
                    expect(userAction) == "N/A"
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
            }
            
            describe("productDetailVisitMoreInfo") {
                beforeEach {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)

                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)

                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)

                    sut = TrackerEvent.productDetailVisitMoreInfo(product)
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
            }

            describe("moreInfoRelatedItemsComplete") {
                beforeEach {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)

                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)

                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)

                    sut = TrackerEvent.moreInfoRelatedItemsComplete(product, itemPosition: 7)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("more-info-related-items-complete"))
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
                it("contains item-position") {
                    let itemPosition = sut.params!.stringKeyParams["item-position"] as? Int
                    expect(itemPosition) == 7
                }
            }

            describe("moreInfoRelatedItemsViewMore") {
                beforeEach {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)

                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)

                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)

                    sut = TrackerEvent.moreInfoRelatedItemsViewMore(product)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("more-info-related-items-view-more"))
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
            }

            describe("productFavorite") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productFavorite(product, typePage: .productDetail)
                    expect(sut.name.rawValue).to(equal("product-detail-favorite"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productFavorite(product, typePage: .productDetail)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.productDetail.rawValue))

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
            
            describe("productShare") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productShare(product, network: EventParameterShareNetwork.email,
                        buttonPosition: .top, typePage: .productDetail)
                    expect(sut.name.rawValue).to(equal("product-detail-share"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productShare(product, network: .email, buttonPosition: .top
                        , typePage: .productDetail)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.productDetail.rawValue))

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
                it("contains the network where the content has been shared") {
                    let product = MockProduct()
                    sut = TrackerEvent.productShare(product, network: .facebook, buttonPosition: .top
                        , typePage: .productDetail)
                    expect(sut.params!.stringKeyParams["share-network"]).notTo(beNil())
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the position of the button used to share") {
                    let product = MockProduct()
                    sut = TrackerEvent.productShare(product, network: .facebook, buttonPosition: .bottom
                        , typePage: .productDetail)
                    expect(sut.params!.stringKeyParams["button-position"]).notTo(beNil())
                    let buttonPosition = sut.params!.stringKeyParams["button-position"] as? String
                    expect(buttonPosition).to(equal("bottom"))
                }
            }
            
            describe("productDetailShareCancel") {
                var product: MockProduct!
                var event: TrackerEvent!
                beforeEach {
                    product = MockProduct()
                    let user = MockUser()
                    user.objectId = "ABCDE"
                    product.user = user
                    product.objectId = "123ABC"
                    event = TrackerEvent.productShareCancel(product, network: .facebook, typePage: .productDetail)
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
            
            describe("productDetailShareComplete") {
                var product: MockProduct!
                var event: TrackerEvent!
                beforeEach {
                    product = MockProduct()
                    let user = MockUser()
                    user.objectId = "ABCDE"
                    product.user = user
                    product.objectId = "123ABC"
                    event = TrackerEvent.productShareComplete(product, network: .facebook, typePage: .productDetail)
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

            describe("product ask question") {
                var product: Product!
                beforeEach {
                    let mockProduct = MockProduct()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .negotiable(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")
                    mockProduct.category = .homeAndGarden

                    let productOwner = MockUser()
                    productOwner.objectId = "67890"
                    mockProduct.user = productOwner
                    mockProduct.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)

                    product = mockProduct
                    sut = TrackerEvent.firstMessage(product, messageType: .text,
                                                          typePage: .productDetail, sellerRating: 4)
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
                it("contains category-id param") {
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId) == product.category.rawValue
                }
                it("contains product-lat param") {
                    let productLat = sut.params!.stringKeyParams["product-lat"] as? Double
                    expect(productLat) == product.location.latitude
                }
                it("contains product-lng param") {
                    let productLng = sut.params!.stringKeyParams["product-lng"] as? Double
                    expect(productLng) == product.location.longitude
                }
                it("contains user-to-id param") {
                    let userToId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(userToId) == product.user.objectId
                }
                it("contains item-type param") {
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains message-type param") {
                    let itemType = sut.params!.stringKeyParams["message-type"] as? String
                    expect(itemType) == "text"
                }
                it("contains type-page param") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage) == "product-detail"
                }
                it("contains seller-user-rating param") {
                    let typePage = sut.params!.stringKeyParams["seller-user-rating"] as? Float
                    expect(typePage) == 4
                }
            }

            describe("product ask question (ChatProduct)") {
                var product: ChatProduct!
                beforeEach {
                    var mockProduct = MockChatProduct()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .negotiable(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")

                    product = mockProduct
                    sut = TrackerEvent.firstMessage(product, messageType: .text, interlocutorId: "67890",
                                                          typePage: .productDetail, sellerRating: 4)
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
                it("contains message-type param") {
                    let itemType = sut.params!.stringKeyParams["message-type"] as? String
                    expect(itemType) == "text"
                }
                it("contains type-page param") {
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage) == "product-detail"
                }
                it("contains seller-user-rating param") {
                    let userRating = sut.params!.stringKeyParams["seller-user-rating"] as? Float
                    expect(userRating) == 4
                }
            }

            describe("Product Detail Open Chat") {
                beforeEach {
                    let mockProduct = MockProduct()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .negotiable(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")

                    sut = TrackerEvent.productDetailOpenChat(mockProduct, typePage: .productDetail)
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

            describe("productMarkAsSold") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsSold(.markAsSold, product: product, freePostingModeAllowed: true)
                    expect(sut.name.rawValue).to(equal("product-detail-sold"))
                }
                it("free-posting param is included as Free") {
                    let product = MockProduct()
                    product.price = .free
                    sut = TrackerEvent.productMarkAsSold(.markAsSold, product: product, freePostingModeAllowed: true)
                    expect(sut.params!.stringKeyParams["free-posting"] as? String).to(equal("true"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productMarkAsSold(.markAsSold, product: product, freePostingModeAllowed: true)
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
            
            describe("productMarkAsUnsold") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsUnsold(product)
                    expect(sut.name.rawValue).to(equal("product-detail-unsold"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = ProductCategory(rawValue: 4)!
                    product.user = myUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    product.category = ProductCategory(rawValue: 4)!
                    
                    sut = TrackerEvent.productMarkAsUnsold(product)
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
            
            describe("productReport") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productReport(product)
                    expect(sut.name.rawValue).to(equal("product-detail-report"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026", state: "Catalonia",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productReport(product)
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

            describe("productSellStart") {
                beforeEach {
                    sut = TrackerEvent.productSellStart(.sell, buttonName: .sellYourStuff,
                        sellButtonPosition: .tabBar)
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
            }

            describe("productSellSharedFB") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productSellSharedFB(product)
                    expect(sut.name.rawValue).to(equal("product-sell-shared-fb"))
                }
                it("contains the product related params when passing by a product") {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    
                    sut = TrackerEvent.productSellSharedFB(product)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }

            describe("productSellComplete") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    product.category = .homeAndGarden
                    product.price = .negotiable(20)
                    sut = TrackerEvent.productSellComplete(product, buttonName: .done, sellButtonPosition: .floatingButton, negotiable: .yes,
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
                    expect(data).to(equal(""))
                }
                it("contains product-description") {
                    let data = sut.params!.stringKeyParams["product-description"] as? Bool
                    expect(data).to(equal(false))
                }
                it("contains number-photos-posting") {
                    let data = sut.params!.stringKeyParams["number-photos-posting"] as? Int
                    expect(data).to(equal(0))
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
            }

            describe("productSellConfirmation") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmation(product)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("productSellConfirmationPost") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmationPost(product, buttonType: .button)
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

            describe("productSellConfirmationEdit") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmationEdit(product)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-edit"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("productSellConfirmationClose") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmationClose(product)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-confirmation-close"))
                }
                it("contains product-id") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal("r4nd0m1D"))
                }
            }

            describe("productSellConfirmationShare") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmationShare(product, network: .facebook)
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

            describe("productSellConfirmationShareCancel") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmationShareCancel(product, network: .facebook)
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

            describe("productSellConfirmationShareComplete") {
                beforeEach {
                    let product = MockProduct()
                    product.objectId = "r4nd0m1D"
                    sut = TrackerEvent.productSellConfirmationShareComplete(product, network: .facebook)
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
                    _ = MockUser()
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
                    sut = TrackerEvent.productEditComplete(nil, product: product, category: nil, editedFields: [])
                    expect(sut.name.rawValue).to(equal("product-edit-complete"))
                }
                it("contains the product related params when passing by a product, name & category") {
                    let product = MockProduct()
                    let newCategory = ProductCategory.carsAndMotors
                    product.objectId = "q1w2e3"

                    sut = TrackerEvent.productEditComplete(nil, product: product, category: newCategory,
                        editedFields: [.title, .category])
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(categoryId).to(equal(newCategory.rawValue))

                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))

                    expect(sut.params!.stringKeyParams["edited-fields"]).notTo(beNil())
                    let editedFields = sut.params!.stringKeyParams["edited-fields"] as? String
                    expect(editedFields).to(equal("title,category"))
                }
            }
            
            describe("productDeleteStart") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDeleteStart(product)
                    expect(sut.name.rawValue).to(equal("product-delete-start"))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productDeleteStart(product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("productDeleteComplete") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productDeleteComplete(product)
                    expect(sut.name.rawValue).to(equal("product-delete-complete"))
                }
                it("contains the product id") {
                    let product = MockProduct()
                    product.objectId = "q1w2e3"
                    sut = TrackerEvent.productDeleteComplete(product)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                }
            }
            
            describe("userMessageSent") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.userMessageSent(product, userTo: nil, messageType: .text, isQuickAnswer: .falseParameter, typePage: .chat)
                    expect(sut.name.rawValue).to(equal("user-sent-message"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013", state: "",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .homeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345", state: "MD",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.userMessageSent(product, userTo: productUser, messageType: .text,
                                                       isQuickAnswer: .falseParameter, typePage: .chat)
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
                    
                    expect(sut.params!.stringKeyParams["item-type"]).notTo(beNil())
                    let itemType = sut.params!.stringKeyParams["item-type"] as? String
                    expect(itemType).to(equal("1"))
                    
                    // the other user
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(productUser.objectId))

                    // Quick answer param

                    expect(sut.params!.stringKeyParams["quick-answer"]).notTo(beNil())
                    let quickAnswer = sut.params!.stringKeyParams["quick-answer"] as? String
                    expect(quickAnswer).to(equal("false"))

                    // Type param
                    expect(sut.params!.stringKeyParams["message-type"]).notTo(beNil())
                    let messageType = sut.params!.stringKeyParams["message-type"] as? String
                    expect(messageType).to(equal("text"))
                }
                it("contains pageType param") {
                    let product = MockProduct()
                    sut = TrackerEvent.userMessageSent(product, userTo: nil, messageType: .text, isQuickAnswer: .falseParameter, typePage: .chat)
                    let pageType = sut.params!.stringKeyParams["type-page"] as? String
                    expect(pageType).to(equal("chat"))
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
                    sut = TrackerEvent.chatRelatedItemsComplete(20, shownReason: .productSold)
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
                        let user = MockUser()
                        user.objectId = "12345"
                        sut = TrackerEvent.profileVisit(user, profileType: .publicParameter , typePage: .productDetail, tab: .selling)
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
            
            describe("profileEditEditLocation") {
                it("has its event name") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .sensor)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    expect(sut.name.rawValue).to(equal("profile-edit-edit-location"))
                }
                it("contains the location type when retrieving from sensors") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .sensor)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("sensor"))
                }
                it("contains the location type when setting manually") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .manual)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("manual"))
                }
                it("contains the location type when retrieving from ip lookup") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .ipLookup)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("iplookup"))
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
                    sut = TrackerEvent.permissionAlertStart(.push, typePage: .productList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.name.rawValue).to(equal("permission-alert-start"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertStart(.push, typePage: .productList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.productList.rawValue))

                    expect(sut.params!.stringKeyParams["alert-type"]).notTo(beNil())
                    let alertType = sut.params!.stringKeyParams["alert-type"] as? String
                    expect(alertType).to(equal(EventParameterPermissionAlertType.custom.rawValue))
                }
            }

            describe("permissionAlertComplete") {
                it("has its event name") {
                    sut = TrackerEvent.permissionAlertComplete(.push, typePage: .productList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.name.rawValue).to(equal("permission-alert-complete"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertComplete(.push, typePage: .productList, alertType: .custom,
                        permissionGoToSettings: .notAvailable)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.productList.rawValue))

                    expect(sut.params!.stringKeyParams["alert-type"]).notTo(beNil())
                    let alertType = sut.params!.stringKeyParams["alert-type"] as? String
                    expect(alertType).to(equal(EventParameterPermissionAlertType.custom.rawValue))
                }
            }

            describe("permissionAlertCancel") {
                it("has its event name") {
                    sut = TrackerEvent.permissionSystemCancel(.push, typePage: .productList)
                    expect(sut.name.rawValue).to(equal("permission-system-cancel"))
                }
                it("contains the permission related params when passing by a permission type & page") {
                    sut = TrackerEvent.permissionSystemCancel(.push, typePage: .productList)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.productList.rawValue))
                }
            }

            describe("permissionSystemComplete") {
                it("has its event name") {
                    sut = TrackerEvent.permissionSystemComplete(.push, typePage: .productList)
                    expect(sut.name.rawValue).to(equal("permission-system-complete"))
                }
                it("contains the permission related params when passing by a permission type & page") {
                    sut = TrackerEvent.permissionSystemComplete(.push, typePage: .productList)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.productList.rawValue))
                }
            }

            describe("userReport") {
                beforeEach {
                    user = MockUser()
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
                    sut = TrackerEvent.profileBlock(.profile, blockedUsersIds: [userId1, userId2])
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
            describe("Notification center complete type welcome") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.welcome)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "welcome"
                }
            }
            describe("Notification center complete type buyersInterested") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.buyersInterested)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "passive-buyer-seller"
                }
            }
            describe("Notification center complete type favorite") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.favorite)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "favorite"
                }
            }
            describe("Notification center complete type productSold") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.productSold)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "favorite-sold"
                }
            }
            describe("Notification center complete type productSuggested") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.productSuggested)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "passive-buyer-make-offer"
                }
            }
            describe("Notification center complete type rating") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.rating)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "rating"
                }
            }
            describe("Notification center complete type ratingUpdated") {
                beforeEach {
                    sut = TrackerEvent.notificationCenterComplete(.ratingUpdated)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "rating-updated"
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
            describe("Passive buyer start") {
                beforeEach {
                    sut = TrackerEvent.passiveBuyerStart(withUser: "123456", productId: "AAAAA")
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("passive-buyer-start"))
                }
                it("contains user-id param") {
                    let param = sut.params!.stringKeyParams["user-id"] as? String
                    expect(param) == "123456"
                }
                it("contains product-id param") {
                    let param = sut.params!.stringKeyParams["product-id"] as? String
                    expect(param).to(equal("AAAAA"))
                }
            }
            describe("Passive buyer complete") {
                beforeEach {
                    sut = TrackerEvent.passiveBuyerComplete(withUser: "123456", productId: "AAAAA", passiveConversations: 3)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("passive-buyer-complete"))
                }
                it("contains user-id param") {
                    let param = sut.params!.stringKeyParams["user-id"] as? String
                    expect(param) == "123456"
                }
                it("contains product-id param") {
                    let param = sut.params!.stringKeyParams["product-id"] as? String
                    expect(param).to(equal("AAAAA"))
                }
                it("contains passive-conversations param") {
                    let param = sut.params!.stringKeyParams["passive-conversations"] as? Int
                    expect(param).to(equal(3))
                }
            }
            describe("Passive buyer abandon") {
                beforeEach {
                    sut = TrackerEvent.passiveBuyerAbandon(withUser: "123456", productId: "AAAAA")
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("passive-buyer-abandon"))
                }
                it("contains user-id param") {
                    let param = sut.params!.stringKeyParams["user-id"] as? String
                    expect(param) == "123456"
                }
                it("contains product-id param") {
                    let param = sut.params!.stringKeyParams["product-id"] as? String
                    expect(param ).to(equal("AAAAA"))
                }
            }
        }
    }
}
