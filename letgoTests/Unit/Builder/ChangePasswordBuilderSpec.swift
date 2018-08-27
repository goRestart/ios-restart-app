import Quick
import Nimble
@testable import LetGoGodMode

final class LGChangePasswordBuilderSpec: QuickSpec {
    override func spec() {
        var subject: ChangePasswordBuilder?
        
        context("when the mode is standard") {
            class NavigationController: UINavigationController {}
            
            beforeEach {
                subject = ChangePasswordBuilder.standard(root: NavigationController())
            }
            
            describe("buildChangePassword") {
                var controller: ChangePasswordViewController?
                
                beforeEach {
                    controller = subject?.buildChangePassword() as! ChangePasswordViewController
                }
                
                it("should have a nice router") {
                    expect(controller?.viewModel.router).toNot(beNil())
                }
                
                it("should create the correct router") {
                    expect(controller?.viewModel.router is ChangePasswordStandardRouter) == true
                }
                
                it("should have a correct view model") {
                    expect(controller?.viewModel).toNot(beNil())
                }
                
                it("should have a correct view controller") {
                    expect(controller).toNot(beNil())
                }
            }
            
            describe("buildChangePassword(withToken)") {
                var controller: ChangePasswordViewController?
                
                beforeEach {
                    controller = subject?.buildChangePassword(withToken: "BATMAN")
                }
                
                it("should have a nice router") {
                    expect(controller?.viewModel.router).toNot(beNil())
                }
                
                it("should create the correct router") {
                    expect(controller?.viewModel.router is ChangePasswordStandardRouter) == true
                }
                
                it("should have a correct view model") {
                    expect(controller?.viewModel).toNot(beNil())
                }
                
                it("should have a correct view controller") {
                    expect(controller).toNot(beNil())
                }
            }
        }
        
        context("when the mode is modal") {
            
            beforeEach {
                subject = ChangePasswordBuilder.modal
            }
            
            describe("buildChangePassword") {
                var controller: ChangePasswordViewController?
                
                beforeEach {
                    controller = subject?.buildChangePassword() as! ChangePasswordViewController
                }
                
                it("should have a nice router") {
                    expect(controller?.viewModel.router).toNot(beNil())
                }
                
                it("should create the correct router") {
                    expect(controller?.viewModel.router is ChangePasswordModalRouter) == true
                }
                
                it("should have a correct view model") {
                    expect(controller?.viewModel).toNot(beNil())
                }
                
                it("should have a correct view controller") {
                    expect(controller).toNot(beNil())
                }
            }
            
            describe("buildChangePassword(withToken)") {
                var controller: ChangePasswordViewController?
                
                beforeEach {
                    controller = subject?.buildChangePassword(withToken: "BATMAN")
                }
                
                it("should have a nice router") {
                    expect(controller?.viewModel.router).toNot(beNil())
                }
                
                it("should create the correct router") {
                    expect(controller?.viewModel.router is ChangePasswordModalRouter) == true
                }
                
                it("should have a correct view model") {
                    expect(controller?.viewModel).toNot(beNil())
                }
                
                it("should have a correct view controller") {
                    expect(controller).toNot(beNil())
                }
            }
        }
        
    }
}
