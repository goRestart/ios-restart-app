import Quick
import Nimble
@testable import LetGoGodMode

final class ChangePasswordModalRouterSpec: QuickSpec {
    override func spec() {
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
        
        var subject: ChangePasswordModalRouter?
        var controller: MockViewController?
        
        beforeEach {
            controller = MockViewController(nibName: nil, bundle: nil)
            subject = ChangePasswordModalRouter(controller: controller!)
        }
        
        describe("closeChangePassword") {
            beforeEach {
                subject?.closeChangePassword()
            }
            
            it("should dismiss the view controller") {
                expect(controller?.wasDismissed) == true
            }
            
            it("should set the correct parameters data") {
                expect(controller?.animation) == true
                expect(controller?.completion).to(beNil())
            }
        }
    }
}
