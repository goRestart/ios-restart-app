@testable import LetGoGodMode
import RxSwift
import RxTest
import Quick
import Nimble

final class DeepLinkMailBoxSpec: QuickSpec {
    
    override func spec() {
        var sut: LGDeepLinkMailBox!
        var deeplinkObserver: TestableObserver<DeepLink>!
        var disposeBag: DisposeBag!
        var scheduler: TestScheduler!
        
        describe("LGDeepLinkMailBox") {
            beforeEach {
                sut = LGDeepLinkMailBox.sharedInstance
                
                scheduler = TestScheduler(initialClock: 0)
                deeplinkObserver = scheduler.createObserver(DeepLink.self)
                disposeBag = DisposeBag()
                
                sut.deeplinks.bind(to: deeplinkObserver).disposed(by: disposeBag)
                scheduler.start()
            }
            
            afterEach {
                scheduler.stop()
                disposeBag = nil
            }
            
            context("pushing a deeplink to the mailbox") {
                beforeEach {
                    let mock = MockDeeplinkConvertible()
                    sut.push(convertible: mock)
                }
                it("should receive emit the received deeplink") {
                    expect(deeplinkObserver.eventValues.count) == 1
                }
            }
        }
    }
}

final class MockDeeplinkConvertible: DeepLinkConvertible {
    var deeplink: DeepLink? = DeepLink.link(.appStore,
                                            campaign: "",
                                            medium: "",
                                            source: .none,
                                            cardActionParameter: "")
    var debugDescription: String { return "I am a cool deeplink" }
}
