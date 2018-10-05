@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift
import RxTest
import LGComponents

final class AppsFlyerAffiliationResolverSpec: QuickSpec {
    override func spec() {
        
        var sut: AppsFlyerAffiliationResolver!
        
        let mockMyUserRepositoryDelay = 0.05
        var delayTime: Double {
            return mockMyUserRepositoryDelay + 0.03
        }
        let disposeBag = DisposeBag()
        let mockAvatar = URL(string: "http://foto.jpg")
        let mockReferrer = ReferrerInfo(userId: String.makeRandom(), name: String.makeRandom(), avatar: mockAvatar)
        let conversionDataMockOk: [AnyHashable : Any] = [
            AppsFlyerKeys.campaign : AppsFlyerAffiliationResolver.campaignValue,
            AppsFlyerKeys.firstLaunch : true,
            AppsFlyerKeys.sub1 : mockReferrer.userId,
            AppsFlyerKeys.sub2 : mockReferrer.name,
            AppsFlyerKeys.sub3 : mockReferrer.avatar!.absoluteString
        ]
        let conversionDataMockKO_notFirstLaunch: [AnyHashable : Any] = [
            AppsFlyerKeys.campaign : AppsFlyerAffiliationResolver.campaignValue,
            AppsFlyerKeys.firstLaunch : false,
            AppsFlyerKeys.sub1 : mockReferrer.userId,
            AppsFlyerKeys.sub2 : mockReferrer.name,
            AppsFlyerKeys.sub3 : mockReferrer.avatar!.absoluteString
        ]
        let conversionDataMockKO_wrongCampaign: [AnyHashable : Any] = [
            AppsFlyerKeys.campaign : String.makeRandom(),
            AppsFlyerKeys.firstLaunch : true,
            AppsFlyerKeys.sub1 : mockReferrer.userId,
            AppsFlyerKeys.sub2 : mockReferrer.name,
            AppsFlyerKeys.sub3 : mockReferrer.avatar!.absoluteString
        ]
        let conversionDataMockKO_noUserIdField: [AnyHashable : Any] = [
            AppsFlyerKeys.campaign : AppsFlyerAffiliationResolver.campaignValue,
            AppsFlyerKeys.firstLaunch : true,
            AppsFlyerKeys.sub2 : mockReferrer.name,
            AppsFlyerKeys.sub3 : mockReferrer.avatar!.absoluteString
        ]


        var myUser = MockMyUser.makeMock()
        myUser.objectId = String.makeRandom()
        
        var observer: TestableObserver<AffiliationCampaignState>!
        
        describe("rx_affiliationCampaign") {
            let scheduler = TestScheduler(initialClock: 0)
            let mockRepo = MockMyUserRepository()
            beforeEach {
                scheduler.start()
                observer = scheduler.createObserver(AffiliationCampaignState.self)
                mockRepo.resultVoid = MyUserVoidResult(value: Void())
                sut = AppsFlyerAffiliationResolver(myUserRepository: mockRepo)
            }
            afterEach {
                mockRepo.myUserVar.value = nil
                scheduler.stop()
            }
            
            context("when all events have been notified correctly") {
                beforeEach {
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("emits an event with referral info when an observer subscribes") {
                    expect(observer.eventValues.last!).toEventually(equal(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified correctly after observing") {
                beforeEach {
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                }
                it("emits an event with referral info") {
                    expect(observer.eventValues.last!).toEventually(equal(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified but the feature is not active") {
                beforeEach {
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    sut.setCampaignFeatureAs(active: false)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                }
                it("emits an inactive feature event") {
                    expect(observer.eventValues.last!).toEventually(equal(.campaignNotAvailableForUser))
                }
            }
            
            context("when all events have been notified except the feature one") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("does not emit campaignNotAvailableForUser") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.campaignNotAvailableForUser))
                }
                it("does not emit referral") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified except the AppsFlyer data") {
                beforeEach {
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("does not emit campaignNotAvailableForUser") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.campaignNotAvailableForUser))
                }
                it("does not emit referral") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified except the login") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    sut.setCampaignFeatureAs(active: true)
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("does not emit campaignNotAvailableForUser") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.campaignNotAvailableForUser))
                }
                it("does not emit referral") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified but data first launch is false") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockKO_notFirstLaunch)
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("does not emit campaignNotAvailableForUser") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.campaignNotAvailableForUser))
                }
                it("does not emit referral") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified but data campaign is wrong") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockKO_wrongCampaign)
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("does not emit campaignNotAvailableForUser") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.campaignNotAvailableForUser))
                }
                it("does not emit referral") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified but data userId is missing") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockKO_noUserIdField)
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("does not emit campaignNotAvailableForUser") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.campaignNotAvailableForUser))
                }
                it("does not emit referral") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(observer.eventValues).toNot(contain(.referral(referrer: mockReferrer)))
                }
            }
            
            context("when all events have been notified correctly and apps flyer data is passed two times the second one with first launch to false") {
                beforeEach {
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.appsFlyerConversionData(data: conversionDataMockKO_notFirstLaunch)
                }
                it("last event emitted is the referral") {
                    expect(observer.eventValues.last!).toEventually(equal(.referral(referrer: mockReferrer)))
                }
            }
        }
        
        // These are the exact same scenarios than the rx_affiliationCampaign tests
        describe("isProbablyReferral") {
            let scheduler = TestScheduler(initialClock: 0)
            let mockRepo = MockMyUserRepository()
            beforeEach {
                scheduler.start()
                observer = scheduler.createObserver(AffiliationCampaignState.self)
                mockRepo.resultVoid = MyUserVoidResult(value: Void())
                sut = AppsFlyerAffiliationResolver(myUserRepository: mockRepo)
            }
            afterEach {
                mockRepo.myUserVar.value = nil
                scheduler.stop()
            }
            
            context("when all events have been notified correctly") {
                beforeEach {
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be true") {
                    expect(sut.isProbablyReferral).to(beTrue())
                }
            }
            
            context("when all events have been notified correctly after observing") {
                beforeEach {
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                }
                it("should be true") {
                    expect(sut.isProbablyReferral).to(beTrue())
                }
            }
            
            context("when all events have been notified but the feature is not active") {
                beforeEach {
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    sut.setCampaignFeatureAs(active: false)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                }
                it("should be false") {
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified except the feature one") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be false") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified except the AppsFlyer data") {
                beforeEach {
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be false") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified except the login") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    sut.setCampaignFeatureAs(active: true)
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be false") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified but data first launch is false") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockKO_notFirstLaunch)
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be false") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified but data campaign is wrong") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockKO_wrongCampaign)
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be false") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified but data userId is missing") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockKO_noUserIdField)
                    sut.setCampaignFeatureAs(active: true)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                }
                it("should be false") {
                    waitUntil { done in delay(delayTime, completion: done) }
                    expect(sut.isProbablyReferral).to(beFalse())
                }
            }
            
            context("when all events have been notified correctly and apps flyer data is passed two times the second one with first launch to false") {
                beforeEach {
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.appsFlyerConversionData(data: conversionDataMockKO_notFirstLaunch)
                }
                it("should be true") {
                    expect(sut.isProbablyReferral).to(beTrue())
                }
            }
        }
        
        // This case is specific for isProbablyReferral
        describe("isProbablyReferral") {
            let scheduler = TestScheduler(initialClock: 0)
            let mockRepo = MockMyUserRepository()
            beforeEach {
                scheduler.start()
                observer = scheduler.createObserver(AffiliationCampaignState.self)
                mockRepo.resultVoid = MyUserVoidResult(value: Void())
                sut = AppsFlyerAffiliationResolver(myUserRepository: mockRepo)
            }
            afterEach {
                mockRepo.myUserVar.value = nil
                scheduler.stop()
            }
            
            context("when is only missing Bouncer confirmation") {
                beforeEach {
                    sut.setCampaignFeatureAs(active: true)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_affiliationCampaign.asObservable().bind(to: observer).disposed(by: disposeBag)
                    // notice that we don't wait for mockRepo to respond
                }
                it("should be true") {
                    expect(sut.isProbablyReferral).to(beTrue())
                }
            }
        }
    }
}
