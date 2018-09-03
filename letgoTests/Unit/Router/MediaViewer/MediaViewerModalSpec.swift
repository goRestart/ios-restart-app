import Quick
import Nimble
@testable import LetGoGodMode

final class MediaViewerModalSpec: QuickSpec {
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

        var sut: MediaViewerModalWireframe!
        var controller: MockViewController!

        beforeEach {
            controller = MockViewController(nibName: nil, bundle: nil)
            sut = MediaViewerModalWireframe(root: controller!)
        }

        describe("closeMediaViewer") {
            beforeEach {
                sut.closeMediaViewer()
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
