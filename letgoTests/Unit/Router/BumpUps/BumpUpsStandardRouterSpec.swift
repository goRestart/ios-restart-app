import Quick
import Nimble
@testable import LetGoGodMode

final class BumpUpsStandardWireframeSpec: QuickSpec {
    override func spec() {
        class MockNavigationController: UINavigationController {
            var popWasCalled: Bool = false
            
            override func popViewController(animated: Bool) -> UIViewController? {
                popWasCalled = true
                super.popViewController(animated: false)
                return nil
            }
        }

        var sut: BumpUpsStandardWireframe!
        var navigationSubject: MockNavigationController!

        beforeEach {
            navigationSubject = MockNavigationController()
            sut = BumpUpsStandardWireframe(nc: navigationSubject)
        }

        describe("bumpUpDidCancel") {
            beforeEach {
                sut.bumpUpDidCancel()
            }

            it("should dismiss the view controller") {
                expect(navigationSubject.popWasCalled) == true
            }
        }

        describe("bumpUpDidFinish") {
            beforeEach {
                sut.bumpUpDidFinish(completion: nil)
            }

            it("should pop the view controller") {
                expect(navigationSubject.popWasCalled) == true
            }
        }
    }
}
