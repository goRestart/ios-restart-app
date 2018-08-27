import Quick
import Nimble
@testable import LetGoGodMode

final class BumpUpsModalWireframeSpec: QuickSpec {
    override func spec() {
        class MockNavigationController: UINavigationController {
            var pushWasCalled: Bool = false

            override func pushViewController(_ viewController: UIViewController, animated: Bool) {
                pushWasCalled = true
                super.pushViewController(viewController, animated: false)
            }
        }

        class MockViewController: UIViewController {
            var wasDismissed: Bool = false
            var animation: Bool?
            var completion: (() -> Void)?

            override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
                wasDismissed = true
                self.animation = flag
                self.completion = completion
            }
        }

        var sut: BumpUpsModalWireframe!
        var controller: MockViewController!

        beforeEach {
            controller = MockViewController(nibName: nil, bundle: nil)
            sut = BumpUpsModalWireframe(root: controller!)
        }

        describe("bumpUpDidCancel") {
            beforeEach {
                sut.bumpUpDidCancel()
            }

            it("should dismiss the view controller") {
                expect(controller.wasDismissed) == true
            }

            it("should set the correct parameters data") {
                expect(controller.animation) == true
                expect(controller.completion).to(beNil())
            }
        }

        describe("bumpUpDidFinish") {
            beforeEach {
                sut.bumpUpDidFinish(completion: nil)
            }

            it("should dismiss the view controller") {
                expect(controller.wasDismissed) == true
            }

            it("should set the correct parameters data") {
                expect(controller.animation) == true
                expect(controller.completion).to(beNil())
            }
        }
    }
}
