import Quick
import Nimble
@testable import LetGoGodMode

final class ChangePasswordStandardRouterSpec: QuickSpec {
    override func spec() {
        class MockNavigationController: UINavigationController {
            var wasPoped: Bool = false
            var animated: Bool?
            
            override func popViewController(animated: Bool) -> UIViewController? {
                wasPoped = true
                self.animated = animated
                return nil
            }
        }
        
        var subject: ChangePasswordStandardRouter?
        var navigator: MockNavigationController?
        
        beforeEach {
            navigator = MockNavigationController(rootViewController: UIViewController())
            subject = ChangePasswordStandardRouter(root: navigator!)
        }
        
        describe("closeChangePassword") {
            beforeEach {
                subject?.closeChangePassword()
            }
            
            it("should pop the view controller") {
                expect(navigator?.wasPoped) == true
            }
            
            it("should set the correct parameters data") {
                expect(navigator?.animated) == true
            }
        }
    }
}
