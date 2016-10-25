
import CoreLocation
@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class TrackerEventSpec: QuickSpec {
    
    override func spec() {
        var sut: TrackerEvent!
        var user: MockUser!
        
        describe("factory methods") {
            describe("location") {
                it("has its event name") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Sensor)!
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    expect(sut.name.rawValue).to(equal("location"))
                }
                it("contains the location type when retrieving from sensors") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Sensor)!
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("sensor"))
                }
                it("contains the location type when setting manually") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Manual)!
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("manual"))
                }
                it("contains the location type when retrieving from ip lookup") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("iplookup"))
                }
                it("contains the location enabled false & location allowed false when location Disabled") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Disabled
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Enabled(.NotDetermined)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Enabled(.Restricted)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Enabled(.Denied)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Enabled(.Authorized)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
                    let locationServiceStatus: LocationServiceStatus = .Enabled(.Authorized)
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
                    sut = TrackerEvent.signupEmail(.Sell, newsletter: .Unset)
                    expect(sut.name.rawValue).to(equal("signup-email"))
                }
                it("contains the appropiate login source signing in via email from posting") {
                    sut = TrackerEvent.signupEmail(.Sell, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("posting"))
                }
                it("contains the appropiate login source signing in via email from chats") {
                    sut = TrackerEvent.signupEmail(.Chats, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("messages"))
                }
                it("contains the appropiate login source signing in via email from profile") {
                    sut = TrackerEvent.signupEmail(.Profile, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("view-profile"))
                }
                it("contains the appropiate login source signing in via email from mark as favourite") {
                    sut = TrackerEvent.signupEmail(.Favourite, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("favourite"))
                }
                it("contains the appropiate login source signing in via email from mark as sold") {
                    sut = TrackerEvent.signupEmail(.MarkAsSold, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("mark-as-sold"))
                }
                it("contains the appropiate login source signing in via email from as a question") {
                    sut = TrackerEvent.signupEmail(.AskQuestion, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("question"))
                }
                it("contains the appropiate login source signing in via email from report fraud") {
                    sut = TrackerEvent.signupEmail(.ReportFraud, newsletter: .Unset)
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
                let error = EventParameterLoginError.Internal(description: "details")
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
                let error = EventParameterLoginError.Internal(description: "details")
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
                let error = EventParameterLoginError.Internal(description: "details")
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
            
            describe("signup error") {
                let error = EventParameterLoginError.Internal(description: "details")
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
                let error = EventParameterLoginError.Internal(description: "details")
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
                    let categories: [ProductCategory] = [.HomeAndGarden]
                    sut = TrackerEvent.productList(nil, categories: categories, searchQuery: nil)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let categoryId = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categoryId).to(equal("4"))
                }
                it("contains the category related params when passing by several categories") {
                    let categories: [ProductCategory] = [.HomeAndGarden, .FashionAndAccesories]
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
                        sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .Success)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue).to(equal("search-complete"))
                    }
                    it("contains the isTrending parameter") {
                        let searchQuery = sut.params!.stringKeyParams["trending-search"] as? Bool
                        expect(searchQuery) == false
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
                        sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", isTrending: false, success: .Failed)
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
                        sut = TrackerEvent.filterComplete(coords, distanceRadius: 10, distanceUnit: DistanceType.Km,
                            categories: [.Electronics, .CarsAndMotors],
                            sortBy: ProductSortCriteria.Distance, postedWithin: ProductTimeCriteria.Day,
                            priceRange: .PriceRange(min: 5, max: 100))
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
                }
                context("not receiving all params, contains the default params") {
                    beforeEach {
                        sut = TrackerEvent.filterComplete(nil, distanceRadius: nil, distanceUnit: DistanceType.Km,
                            categories: nil, sortBy: nil, postedWithin: nil, priceRange: .PriceRange(min: nil, max: nil))
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
                }
            }
            
            describe("productDetailVisit") {
                beforeEach {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)

                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)

                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)

                    sut = TrackerEvent.productDetailVisit(product, visitUserAction: .None, source: .ProductList)
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
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)

                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)

                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
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
            
            

            describe("productFavorite") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productFavorite(product, typePage: .ProductDetail)
                    expect(sut.name.rawValue).to(equal("product-detail-favorite"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productFavorite(product, typePage: .ProductDetail)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.ProductDetail.rawValue))

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
                    sut = TrackerEvent.productShare(product, network: EventParameterShareNetwork.Email,
                        buttonPosition: .Top, typePage: .ProductDetail)
                    expect(sut.name.rawValue).to(equal("product-detail-share"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productShare(product, network: .Email, buttonPosition: .Top
                        , typePage: .ProductDetail)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.ProductDetail.rawValue))

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
                    sut = TrackerEvent.productShare(product, network: .Facebook, buttonPosition: .Top
                        , typePage: .ProductDetail)
                    expect(sut.params!.stringKeyParams["share-network"]).notTo(beNil())
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the position of the button used to share") {
                    let product = MockProduct()
                    sut = TrackerEvent.productShare(product, network: .Facebook, buttonPosition: .Bottom
                        , typePage: .ProductDetail)
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
                    event = TrackerEvent.productShareCancel(product, network: .Facebook, typePage: .ProductDetail)
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
                    event = TrackerEvent.productShareComplete(product, network: .Facebook, typePage: .ProductDetail)
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
                    mockProduct.price = .Negotiable(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")
                    mockProduct.category = .HomeAndGarden

                    let productOwner = MockUser()
                    productOwner.objectId = "67890"
                    mockProduct.user = productOwner
                    mockProduct.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)

                    product = mockProduct
                    sut = TrackerEvent.productAskQuestion(product, messageType: .Text,
                                                          typePage: .ProductDetail, sellerRating: 4)
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
                    let typePage = sut.params!.stringKeyParams["seller-user-rating"] as? Int
                    expect(typePage) == 4
                }
            }

            describe("product ask question (ChatProduct)") {
                var product: ChatProduct!
                beforeEach {
                    var mockProduct = MockChatProduct()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .Negotiable(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")

                    product = mockProduct
                    sut = TrackerEvent.productAskQuestion(product, messageType: .Text, interlocutorId: "67890",
                                                          typePage: .ProductDetail, sellerRating: 4)
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
                    let typePage = sut.params!.stringKeyParams["seller-user-rating"] as? Int
                    expect(typePage) == 4
                }
            }

            describe("Product Detail Chat Button") {
                beforeEach {
                    let mockProduct = MockProduct()
                    mockProduct.objectId = "12345"
                    mockProduct.price = .Negotiable(123.983)
                    mockProduct.currency = Currency(code: "EUR", symbol: "€")

                    sut = TrackerEvent.productDetailChatButton(mockProduct, typePage: .ProductDetail)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-detail-chat-button"))
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
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product)
                    expect(sut.name.rawValue).to(equal("product-detail-sold"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let myUser = MockUser()
                    myUser.objectId = "12345"
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product)
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
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = ProductCategory(rawValue: 4)!
                    product.user = myUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
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
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
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
                    sut = TrackerEvent.productSellStart(.Sell, buttonName: .SellYourStuff)
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
            }

            describe("productSellFormValidationFailed") {
                it("has its event name") {
                    _ = MockUser()
                    sut = TrackerEvent.productSellFormValidationFailed("whatever")
                    expect(sut.name.rawValue).to(equal("product-sell-form-validation-failed"))
                }
                it("contains the description related params") {
                    sut = TrackerEvent.productSellFormValidationFailed("whatever")
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["description"] as? String
                    expect(description).to(equal("whatever"))
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
                    product.category = .HomeAndGarden

                    sut = TrackerEvent.productSellComplete(product, buttonName: .Done, negotiable: .Yes,
                        pictureSource: .Gallery)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("product-sell-complete"))
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
                it("contains button-name") {
                    let data = sut.params!.stringKeyParams["button-name"] as? String
                    expect(data).to(equal("done"))
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
                    let newCategory = ProductCategory.CarsAndMotors
                    product.objectId = "q1w2e3"

                    sut = TrackerEvent.productEditComplete(nil, product: product, category: newCategory,
                        editedFields: [.Title, .Category])
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
                    sut = TrackerEvent.userMessageSent(product, userTo: nil, messageType: .Text, isQuickAnswer: .False)
                    expect(sut.name.rawValue).to(equal("user-sent-message"))
                }
                it("contains the product related params when passing by a product and my user") {
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = .Negotiable(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.userMessageSent(product, userTo: productUser, messageType: .Text,
                                                       isQuickAnswer: .False)
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
            }

            describe("chatRelatedItemsStart") {
                beforeEach {
                    sut = TrackerEvent.chatRelatedItemsStart(.Unanswered48h)
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
                    sut = TrackerEvent.chatRelatedItemsComplete(20, shownReason: .ProductSold)
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
                        sut = TrackerEvent.profileVisit(user, typePage: .ProductDetail, tab: .Selling)
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
                    let lgLocation = LGLocation(location: location, type: .Sensor)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    expect(sut.name.rawValue).to(equal("profile-edit-edit-location"))
                }
                it("contains the location type when retrieving from sensors") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Sensor)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("sensor"))
                }
                it("contains the location type when setting manually") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Manual)!
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("manual"))
                }
                it("contains the location type when retrieving from ip lookup") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .IPLookup)!
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
                    sut = TrackerEvent.profileShareStart(.Public)
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
                    sut = TrackerEvent.profileShareComplete(.Public, shareNetwork: .Facebook)
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
                    sut = TrackerEvent.appInviteFriendStart(.Settings)
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
                    sut = TrackerEvent.appInviteFriend(.Facebook, typePage: .Settings)
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
                    sut = TrackerEvent.appInviteFriendDontAsk(.Settings)
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
                    sut = TrackerEvent.appInviteFriendCancel(.Facebook, typePage: .Settings)
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
                    sut = TrackerEvent.appInviteFriendComplete(.Facebook, typePage: .Settings)
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
                    sut = TrackerEvent.permissionAlertStart(.Push, typePage: .ProductList, alertType: .Custom,
                        permissionGoToSettings: .NotAvailable)
                    expect(sut.name.rawValue).to(equal("permission-alert-start"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertStart(.Push, typePage: .ProductList, alertType: .Custom,
                        permissionGoToSettings: .NotAvailable)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.Push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.ProductList.rawValue))

                    expect(sut.params!.stringKeyParams["alert-type"]).notTo(beNil())
                    let alertType = sut.params!.stringKeyParams["alert-type"] as? String
                    expect(alertType).to(equal(EventParameterPermissionAlertType.Custom.rawValue))
                }
            }

            describe("permissionAlertComplete") {
                it("has its event name") {
                    sut = TrackerEvent.permissionAlertComplete(.Push, typePage: .ProductList, alertType: .Custom,
                        permissionGoToSettings: .NotAvailable)
                    expect(sut.name.rawValue).to(equal("permission-alert-complete"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertComplete(.Push, typePage: .ProductList, alertType: .Custom,
                        permissionGoToSettings: .NotAvailable)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.Push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.ProductList.rawValue))

                    expect(sut.params!.stringKeyParams["alert-type"]).notTo(beNil())
                    let alertType = sut.params!.stringKeyParams["alert-type"] as? String
                    expect(alertType).to(equal(EventParameterPermissionAlertType.Custom.rawValue))
                }
            }

            describe("permissionAlertCancel") {
                it("has its event name") {
                    sut = TrackerEvent.permissionSystemCancel(.Push, typePage: .ProductList)
                    expect(sut.name.rawValue).to(equal("permission-system-cancel"))
                }
                it("contains the permission related params when passing by a permission type & page") {
                    sut = TrackerEvent.permissionSystemCancel(.Push, typePage: .ProductList)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.Push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.ProductList.rawValue))
                }
            }

            describe("permissionSystemComplete") {
                it("has its event name") {
                    sut = TrackerEvent.permissionSystemComplete(.Push, typePage: .ProductList)
                    expect(sut.name.rawValue).to(equal("permission-system-complete"))
                }
                it("contains the permission related params when passing by a permission type & page") {
                    sut = TrackerEvent.permissionSystemComplete(.Push, typePage: .ProductList)
                    expect(sut.params).notTo(beNil())

                    expect(sut.params!.stringKeyParams["permission-type"]).notTo(beNil())
                    let permissionType = sut.params!.stringKeyParams["permission-type"] as? String
                    expect(permissionType).to(equal(EventParameterPermissionType.Push.rawValue))

                    expect(sut.params!.stringKeyParams["type-page"]).notTo(beNil())
                    let typePage = sut.params!.stringKeyParams["type-page"] as? String
                    expect(typePage).to(equal(EventParameterTypePage.ProductList.rawValue))
                }
            }

            describe("userReport") {
                beforeEach {
                    user = MockUser()
                    user.objectId = "test-id"
                    sut = TrackerEvent.profileReport(.Profile, reportedUserId: user.objectId!, reason: .Scammer)
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
                    sut = TrackerEvent.profileBlock(.Profile, blockedUsersIds: [userId1, userId2])
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
                    sut = TrackerEvent.profileUnblock(.Profile, unblockedUsersIds: [userId1, userId2])
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
                    sut = TrackerEvent.userRatingStart("12345", typePage: .Chat)
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
                    sut = TrackerEvent.userRatingComplete("12345", typePage: .Chat, rating: 4, hasComments: true)
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
                        sut = TrackerEvent.openAppExternal("ut_campaign", medium: "ut_medium", source: .External(source: "ut_source"))
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
                        sut = TrackerEvent.openAppExternal(nil, medium: nil, source: .None)
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
                        sut = TrackerEvent.expressChatStart()
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "express-chat-start"
                    }
                }

                context("express chat complete") {
                    beforeEach {
                        sut = TrackerEvent.expressChatComplete(3)
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "express-chat-complete"
                    }
                    it("contains type-page param") {
                        let expressConversations = sut.params!.stringKeyParams["express-conversations"] as? Int
                        expect(expressConversations) == 3
                    }
                }

                context("express chat don't ask again") {
                    beforeEach {
                        sut = TrackerEvent.expressChatDontAsk()
                    }
                    it("has its event name") {
                        expect(sut.name.rawValue) == "express-chat-dont-ask"
                    }
                }
            }

            describe("product detail interested users") {
                beforeEach {
                    sut = TrackerEvent.productDetailInterestedUsers(3, productId: "ABCD")
                }
                it("has its event name") {
                    expect(sut.name.rawValue) == "product-detail-interested-users"
                }
                it("contains number-of-users param") {
                    let numUSers = sut.params!.stringKeyParams["number-of-users"] as? Int
                    expect(numUSers) == 3
                }
                it("contains product-id param") {
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "ABCD"
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
                        sut = TrackerEvent.verifyAccountStart(.Chat)
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
                        sut = TrackerEvent.verifyAccountComplete(.Chat, network: .Facebook)
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
                    sut = TrackerEvent.InappChatNotificationStart()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("in-app-chat-notification-start"))
                }
            }
            describe("In app chat notification complete") {
                beforeEach {
                    sut = TrackerEvent.InappChatNotificationComplete()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("in-app-chat-notification-complete"))
                }
            }
            describe("Signup captcha") {
                beforeEach {
                    sut = TrackerEvent.SignupCaptcha()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("signup-captcha"))
                }
            }
            describe("Notification center start") {
                beforeEach {
                    sut = TrackerEvent.NotificationCenterStart()
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-start"))
                }
            }
            describe("Notification center complete") {
                beforeEach {
                    sut = TrackerEvent.NotificationCenterComplete(.Welcome)
                }
                it("has its event name") {
                    expect(sut.name.rawValue).to(equal("notification-center-complete"))
                }
                it("contains notification-type param") {
                    let param = sut.params!.stringKeyParams["notification-type"] as? String
                    expect(param) == "welcome"
                }
            }
        }
    }
}
