import CoreLocation
import LetGo
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
                    let lgLocation = LGLocation(location: location, type: .Sensor)
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    expect(sut.name.rawValue).to(equal("location"))
                }
                it("contains the location type when retrieving from sensors") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Sensor)
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("sensor"))
                }
                it("contains the location type when setting manually") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Manual)
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("manual"))
                }
                it("contains the location type when retrieving from ip lookup") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
                    let locationServiceStatus: LocationServiceStatus = .Disabled
                    sut = TrackerEvent.location(lgLocation, locationServiceStatus: locationServiceStatus)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("iplookup"))
                }
                it("contains the location enabled false & location allowed false when location Disabled") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                it("contains the appropiate login source signing in via email from make an offer") {
                    sut = TrackerEvent.signupEmail(.MakeOffer, newsletter: .Unset)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["login-type"]).notTo(beNil())
                    let loginType = sut.params!.stringKeyParams["login-type"] as? String
                    expect(loginType).to(equal("offer"))
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

            describe("login error") {
                it("has its event name") {
                    sut = TrackerEvent.loginError(.Network)
                    expect(sut.name.rawValue).to(equal("login-error"))
                }
                it("contains the error description param") {
                    let errorDescription = EventParameterLoginError.Network
                    sut = TrackerEvent.loginError(errorDescription)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["error-description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["error-description"] as? String
                    expect(description).to(equal(errorDescription.description))
                }
            }
            
            describe("signup error") {
                it("has its event name") {
                    sut = TrackerEvent.signupError(.Network)
                    expect(sut.name.rawValue).to(equal("signup-error"))
                }
                it("contains the error description param") {
                    let errorDescription = EventParameterLoginError.Network
                    sut = TrackerEvent.signupError(errorDescription)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["error-description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["error-description"] as? String
                    expect(description).to(equal(errorDescription.description))
                }
            }
            
            describe("password reset error error") {
                it("has its event name") {
                    sut = TrackerEvent.passwordResetError(.Network)
                    expect(sut.name.rawValue).to(equal("password-reset-error"))
                }
                it("contains the error description param") {
                    
                    let errorDescription = EventParameterLoginError.Network
                    sut = TrackerEvent.passwordResetError(errorDescription)
                    expect(sut.params).notTo(beNil())
                    
                    expect(sut.params!.stringKeyParams["error-description"]).notTo(beNil())
                    let description = sut.params!.stringKeyParams["error-description"] as? String
                    expect(description).to(equal(errorDescription.description))
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
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "", success: .Success)
                    expect(sut.name.rawValue).to(equal("search-complete"))
                }
                it("contains the search keyword related params when passing by the search query") {
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", success: .Success)
                    
                    expect(sut.params!.stringKeyParams["search-keyword"]).notTo(beNil())
                    let searchQuery = sut.params!.stringKeyParams["search-keyword"] as? String
                    expect(searchQuery).to(equal("iPhone"))
                }
                it("search had results") {
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "iPhone", success: .Success)

                    expect(sut.params!.stringKeyParams["search-success"]).notTo(beNil())
                    let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                    expect(searchSuccess).to(equal("yes"))
                }
                it("search had no results") {
                    sut = TrackerEvent.searchComplete(nil, searchQuery: "weirdsearchterm", success: .Failed)

                    expect(sut.params!.stringKeyParams["search-success"]).notTo(beNil())
                    let searchSuccess = sut.params!.stringKeyParams["search-success"] as? String
                    expect(searchSuccess).to(equal("no"))
                }
            }
             

            describe("filterStart") {
                it("has its event name") {
                    sut = TrackerEvent.filterStart()
                    expect(sut.name.rawValue).to(equal("filter-start"))
                }
            }
            
            describe("filterComplete") {
                it("has its event name") {
                    let coords = LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123)
                    sut = TrackerEvent.filterComplete(coords, distanceRadius: 10, distanceUnit: DistanceType.Km, categories: [ProductCategory.Electronics, ProductCategory.CarsAndMotors], sortBy: ProductSortCriteria.Distance)
                    expect(sut.name.rawValue).to(equal("filter-complete"))
                }
                it("when receiving all params, contains the related params ") {
                    let coords = LGLocationCoordinates2D(latitude: 41.123, longitude: 2.123)
                    sut = TrackerEvent.filterComplete(coords, distanceRadius: 10, distanceUnit: DistanceType.Km, categories: [ProductCategory.Electronics, ProductCategory.CarsAndMotors], sortBy: ProductSortCriteria.Distance)
                    
                    expect(sut.params!.stringKeyParams["filter-lat"]).notTo(beNil())
                    let lat = sut.params!.stringKeyParams["filter-lat"] as? Double
                    expect(lat).to(equal(41.123))

                    expect(sut.params!.stringKeyParams["filter-lng"]).notTo(beNil())
                    let lng = sut.params!.stringKeyParams["filter-lng"] as? Double
                    expect(lng).to(equal(2.123))

                    let categories = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categories).to(equal("1,2"))
                }

                it("when not receiving all params, contains the default params ") {

                    sut = TrackerEvent.filterComplete(nil, distanceRadius: nil, distanceUnit: DistanceType.Km, categories: nil, sortBy: ProductSortCriteria.Distance)
                    
                    expect(sut.params!.stringKeyParams["filter-lat"]).notTo(beNil())
                    let lat = sut.params!.stringKeyParams["filter-lat"] as? String
                    expect(lat).to(equal("default"))
                    
                    expect(sut.params!.stringKeyParams["filter-lng"]).notTo(beNil())
                    let lng = sut.params!.stringKeyParams["filter-lat"] as? String
                    expect(lng).to(equal("default"))
                    
                    let categories = sut.params!.stringKeyParams["category-id"] as? String
                    expect(categories).to(equal("0"))
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
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = Double(123.2)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productDetailVisit(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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

            describe("productFavorite") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productFavorite(product, user: nil, typePage: .ProductDetail)
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
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productFavorite(product, user: myUser, typePage: .ProductDetail)
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
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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
                    sut = TrackerEvent.productShare(product, user: nil, network: EventParameterShareNetwork.Email,
                        buttonPosition: .Top, typePage: .ProductDetail)
                    expect(sut.name.rawValue).to(equal("product-detail-share"))
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
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productShare(product, user: myUser, network: .Email, buttonPosition: .Top
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
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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
                    sut = TrackerEvent.productShare(product, user: nil, network: .Facebook, buttonPosition: .Top
                        , typePage: .ProductDetail)
                    expect(sut.params!.stringKeyParams["share-network"]).notTo(beNil())
                    let network = sut.params!.stringKeyParams["share-network"] as? String
                    expect(network).to(equal("facebook"))
                }
                it("contains the position of the button used to share") {
                    let product = MockProduct()
                    sut = TrackerEvent.productShare(product, user: nil, network: .Facebook, buttonPosition: .Bottom
                        , typePage: .ProductDetail)
                    expect(sut.params!.stringKeyParams["button-position"]).notTo(beNil())
                    let buttonPosition = sut.params!.stringKeyParams["button-position"] as? String
                    expect(buttonPosition).to(equal("bottom"))
                }
            }
            
            describe("productDetailShareCancel") {
                var product: MockProduct!
                var user: MockUser!
                var tracker: TrackerEvent!
                beforeEach {
                    product = MockProduct()
                    product.objectId = "123ABC"
                    user = MockUser()
                    tracker = TrackerEvent.productShareCancel(product, user: user, network: .Facebook
                        , typePage: .ProductDetail)
                }
                it("has the correct event name") {
                    expect(tracker.name.rawValue) == "product-detail-share-cancel"
                }
                it("has non nil params") {
                    expect(tracker.params).toNot(beNil())
                }
                it("contains the item-type param") {
                    let itemType = tracker.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains the network where the content has been shared") {
                    let network = tracker.params!.stringKeyParams["share-network"] as? String
                    expect(network) == "facebook"
                }
                it("contains the product being shared") {
                    let productId = tracker.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "123ABC"
                }
            }
            
            describe("productDetailShareComplete") {
                var product: MockProduct!
                var user: MockUser!
                var tracker: TrackerEvent!
                beforeEach {
                    product = MockProduct()
                    product.objectId = "123ABC"
                    user = MockUser()
                    tracker = TrackerEvent.productShareComplete(product, user: user, network: .Facebook
                        , typePage: .ProductDetail)
                }
                it("has the correct event name") {
                    expect(tracker.name.rawValue) == "product-detail-share-complete"
                }
                it("has non nil params") {
                    expect(tracker.params).toNot(beNil())
                }
                it("contains the item-type param") {
                    let itemType = tracker.params!.stringKeyParams["item-type"] as? String
                    expect(itemType) == "1"
                }
                it("contains the network where the content has been shared") {
                    let network = tracker.params!.stringKeyParams["share-network"] as? String
                    expect(network) == "facebook"
                }
                it("contains the product being shared") {
                    let productId = tracker.params!.stringKeyParams["product-id"] as? String
                    expect(productId) == "123ABC"
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
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    productUser.isDummy = true
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productOffer(product, user: myUser, amount: 0)
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
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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
                    expect(itemType).to(equal("0"))
                    
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
                    sut = TrackerEvent.productAskQuestion(product, user: nil, typePage: .ProductDetail)
                    expect(sut.name.rawValue).to(equal("product-detail-ask-question"))
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
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productAskQuestion(product, user: myUser, typePage: .ProductDetail)
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
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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
            
            describe("productMarkAsSold") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product, user: nil)
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
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productMarkAsSold(.MarkAsSold, product: product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.category.rawValue))
                    
                }
            }
            
            describe("productMarkAsUnsold") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productMarkAsUnsold(product, user: nil)
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
                    product.price = 123.983
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = ProductCategory(rawValue: 4)!
                    product.user = myUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    product.category = ProductCategory(rawValue: 4)!
                    
                    sut = TrackerEvent.productMarkAsUnsold(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
                    expect(sut.params!.stringKeyParams["category-id"]).notTo(beNil())
                    let productCategory = sut.params!.stringKeyParams["category-id"] as? Int
                    expect(productCategory).to(equal(product.category.rawValue))
                }
            }
            
            describe("productReport") {
                it("has its event name") {
                    let product = MockProduct()
                    sut = TrackerEvent.productReport(product, user: nil)
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
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.productReport(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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
                it("has its event name") {
                    let user = MockUser()
                    sut = TrackerEvent.productSellStart(user)
                    expect(sut.name.rawValue).to(equal("product-sell-start"))
                }
            }
            
            describe("productSellFormValidationFailed") {
                it("has its event name") {
                    _ = MockUser()
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
                    product.category = .HomeAndGarden
                    
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
                    myUser.postalAddress = PostalAddress(address: nil, city: "Barcelona", zipCode: "08026",
                        countryCode: "ES", country: nil)
                    
                    let productUser = MockUser()
                    productUser.objectId = "56897"
                    productUser.postalAddress = PostalAddress(address: nil, city: "Amsterdam", zipCode: "GD 1013",
                        countryCode: "NL", country: nil)
                    
                    let product = MockProduct()
                    product.objectId = "AAAAA"
                    product.name = "iPhone 7S"
                    product.price = Double(123.983)
                    product.currency = Currency(code: "EUR", symbol: "€")
                    product.category = .HomeAndGarden
                    product.user = productUser
                    product.location = LGLocationCoordinates2D(latitude: 3.12354534, longitude: 7.23983292)
                    product.postalAddress = PostalAddress(address: nil, city: "Baltimore", zipCode: "12345",
                        countryCode: "US", country: nil)
                    
                    sut = TrackerEvent.userMessageSent(product, user: myUser)
                    expect(sut.params).notTo(beNil())
                    
                    // Product
                    
                    expect(sut.params!.stringKeyParams["product-id"]).notTo(beNil())
                    let productId = sut.params!.stringKeyParams["product-id"] as? String
                    expect(productId).to(equal(product.objectId))
                    
                    expect(sut.params!.stringKeyParams["product-price"]).notTo(beNil())
                    let productPrice = sut.params!.stringKeyParams["product-price"] as? Double
                    expect(productPrice).to(equal(product.price!))
                    
                    expect(sut.params!.stringKeyParams["product-currency"]).notTo(beNil())
                    let productCurrency = sut.params!.stringKeyParams["product-currency"] as? String
                    expect(productCurrency).to(equal(product.currency!.code))
                    
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
                    
                    // Product user / the other user
                    
                    expect(sut.params!.stringKeyParams["user-to-id"]).notTo(beNil())
                    let productUserId = sut.params!.stringKeyParams["user-to-id"] as? String
                    expect(productUserId).to(equal(product.user.objectId))
                    
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
                    let lgLocation = LGLocation(location: location, type: .Sensor)
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    expect(sut.name.rawValue).to(equal("profile-edit-edit-location"))
                }
                it("contains the location type when retrieving from sensors") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Sensor)
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("sensor"))
                }
                it("contains the location type when setting manually") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .Manual)
                    sut = TrackerEvent.profileEditEditLocation(lgLocation)
                    
                    expect(sut.params).notTo(beNil())
                    expect(sut.params!.stringKeyParams["location-type"]).notTo(beNil())
                    let locationType = sut.params!.stringKeyParams["location-type"] as? String
                    expect(locationType).to(equal("manual"))
                }
                it("contains the location type when retrieving from ip lookup") {
                    let location = CLLocation(latitude: 42, longitude: 2)
                    let lgLocation = LGLocation(location: location, type: .IPLookup)
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
                        systemAlertSeen: .False)
                    expect(sut.name.rawValue).to(equal("permission-alert-start"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertStart(.Push, typePage: .ProductList, alertType: .Custom,
                        systemAlertSeen: .False)
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
                        systemAlertSeen: .False)
                    expect(sut.name.rawValue).to(equal("permission-alert-complete"))
                }
                it("contains the permission related params when passing by a permission type, page & alertType") {
                    sut = TrackerEvent.permissionAlertComplete(.Push, typePage: .ProductList, alertType: .Custom,
                        systemAlertSeen: .False)
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
                    sut = TrackerEvent.profileReport(.Profile, reportedUser: user, reason: .Scammer)
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
        }
    }
}
