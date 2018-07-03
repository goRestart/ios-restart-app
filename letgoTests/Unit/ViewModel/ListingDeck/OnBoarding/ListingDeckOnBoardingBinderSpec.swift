@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble
import LGComponents

class ListingDeckOnBoardingBinderSpec: QuickSpec {

    override func spec() {
        var sut: ListingDeckOnBoardingBinder!
        var viewController: MockListingDeckOnBoardingViewControllerType!
        var view: MockListingDeckOnBoardingViewRxType!

        describe("ListingDeckOnBoardingBinderSpec") {
            beforeEach {
                sut = ListingDeckOnBoardingBinder()
                viewController = MockListingDeckOnBoardingViewControllerType()
                view = MockListingDeckOnBoardingViewRxType()
            }

            afterEach {
                viewController.resetVariables()
            }

            context("the confirm button is tapped") {
                beforeEach {
                    sut.viewController = viewController

                    sut.bind(withView: view)
                    view.confirmButton.sendActions(for: .touchUpInside)
                }
                it("close method is called") {
                    expect(viewController.isCloseCalled) == 1
                }
            }

            context("we dealloc the viewcontroller") {
                beforeEach {
                    sut.viewController = viewController
                    sut.bind(withView: view)
                    viewController = MockListingDeckOnBoardingViewControllerType()
                }
                it("and the binder's viewcontroller reference dies too (so weak)") {
                    expect(sut.viewController).toEventually(beNil())
                }
            }
        }
    }
}

private class MockListingDeckOnBoardingViewRxType: ListingDeckOnBoardingViewRxType {
    var rxConfirmButton: Reactive<LetgoButton> { return confirmButton.rx }
    var confirmButton = LetgoButton(withStyle: .terciary)
}   

private class MockListingDeckOnBoardingViewControllerType: ListingDeckOnBoardingViewControllerType {
    var isCloseCalled: Int = 0

    func resetVariables() {
        isCloseCalled = 0
    }

    func close() {
        isCloseCalled += 1
    }
}
