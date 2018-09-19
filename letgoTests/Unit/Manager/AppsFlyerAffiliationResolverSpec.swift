@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift
import RxTest

final class AppsFlyerAffiliationResolverSpec: QuickSpec {
    override func spec() {
        
        var sut: AppsFlyerAffiliationResolver!
        
        let disposeBag = DisposeBag()
        let mockAvatar = URL(string: "http://foto.jpg")
        let mockReferrer = ReferrerInfo(userId: String.makeRandom(), name: String.makeRandom(), avatar: mockAvatar)
        let conversionDataMockOk: [AnyHashable : Any] = [
            AppsFlyerKeys.campaign : AppsFlyerAffiliationResolver.campaignValue,
            AppsFlyerKeys.firstLaunch : true,
            AppsFlyerKeys.sub1 : mockReferrer.userId,
            AppsFlyerKeys.sub2 : mockReferrer.name,
            AppsFlyerKeys.sub3 : mockReferrer.avatar!
        ]
        var myUser = MockMyUser.makeMock()
        myUser.objectId = String.makeRandom()
        
        var observerReferrer: TestableObserver<ReferrerInfo?>!
        var observerReferredOutsideABTest: TestableObserver<Bool>!
        
        describe("rx_referrer") {
            let scheduler = TestScheduler(initialClock: 0)
            let mockRepo = MockMyUserRepository()
            beforeEach {
                scheduler.start()
                observerReferrer = scheduler.createObserver(Optional<ReferrerInfo>.self)
                mockRepo.resultVoid = MyUserVoidResult(value: Void())
                sut = AppsFlyerAffiliationResolver(myUserRepository: mockRepo)
            }
            afterEach {
                mockRepo.myUserVar.value = nil
                scheduler.stop()
            }
            
            context("when all events have been notified correctly") {
                beforeEach {
                    sut.activateFeature()
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_referrer.asObservable().bind(to: observerReferrer).disposed(by: disposeBag)
                }
                it("emits an event with referrerInfo when an observer subscribes") {
                    expect(observerReferrer.eventValues.last!).toEventually(equal(mockReferrer))
                }
            }
            
            context("when all events have been notified correctly after observing") {
                beforeEach {
                    sut.rx_referrer.asObservable().bind(to: observerReferrer).disposed(by: disposeBag)
                    sut.activateFeature()
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                }
                it("emits an event with referrerInfo") {
                    expect(observerReferrer.eventValues.last!).toEventually(equal(mockReferrer))
                }
            }
            
            context("when the feature has not been activated") {
                beforeEach {
                    sut.rx_referrer.asObservable().bind(to: observerReferrer).disposed(by: disposeBag)
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                }
                it("does not emit referrerInfo event") {
                    expect(observerReferrer.eventValues).toEventuallyNot(equal([nil, mockReferrer]))
                }
            }
            
        }
        
        describe("rx_referredOutsideABTest") {
            let scheduler = TestScheduler(initialClock: 0)
            let mockRepo = MockMyUserRepository()
            beforeEach {
                scheduler.start()
                observerReferredOutsideABTest = scheduler.createObserver(Bool.self)
                mockRepo.resultVoid = MyUserVoidResult(value: Void())
                sut = AppsFlyerAffiliationResolver(myUserRepository: mockRepo)
            }
            afterEach {
                mockRepo.myUserVar.value = nil
                scheduler.stop()
            }
            
            context("when all events have been notified correctly except the feature flag") {
                beforeEach {
                    sut.appsFlyerConversionData(data: conversionDataMockOk)
                    mockRepo.myUserVar.value = myUser
                    sut.userLoggedIn()
                    sut.rx_referredOutsideABTest.asObservable().bind(to: observerReferredOutsideABTest).disposed(by: disposeBag)
                }
                it("emits an event when an observer subscribes") {
                    expect(observerReferredOutsideABTest.eventValues.last!).toEventually(beTrue())
                }
            }
        }

    }
}
