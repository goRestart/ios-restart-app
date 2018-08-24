import Quick
import Nimble
@testable import LetGoGodMode

final class MediaViewerStandardSpec: QuickSpec {
    override func spec() {
        class MockNavigationController: UINavigationController {
            var pushWasCalled: Bool = false
            var popWasCalled: Bool = false

            override func pushViewController(_ viewController: UIViewController, animated: Bool) {
                pushWasCalled = true
                super.pushViewController(viewController, animated: false)
            }

            override func popViewController(animated: Bool) -> UIViewController? {
                popWasCalled = true
                super.popViewController(animated: false)
                return nil
            }
        }

        var subject: MediaViewerStandardWireframe!
        var navigationSubject: MockNavigationController!

        beforeEach {
            navigationSubject = MockNavigationController()
            subject = MediaViewerStandardWireframe(nc: navigationSubject)
        }

        describe("closeMediaViewer") {
            beforeEach {
                subject.closeMediaViewer()
            }

            it("should pop the view controller") {
                expect(navigationSubject.popWasCalled) == true
            }
        }
    }
}
