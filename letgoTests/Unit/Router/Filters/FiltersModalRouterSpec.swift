import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode

final class FiltersModalWireframeSpec: QuickSpec {
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
        
        var subject: FiltersModalWireframe?
        var navigationSubject: MockNavigationController?
        var controller: MockViewController?
        
        beforeEach {
            controller = MockViewController(nibName: nil, bundle: nil)
            navigationSubject = MockNavigationController(rootViewController: controller!)
            subject = FiltersModalWireframe(controller: controller!, nc: navigationSubject!)
        }
        
        describe("closeFilters") {
            beforeEach {
                subject?.closeFilters()
            }
            
            it("should dismiss the view controller") {
                expect(controller?.wasDismissed) == true
            }
            
            it("should set the correct parameters data") {
                expect(controller?.animation) == true
                expect(controller?.completion).to(beNil())
            }
        }
        
        describe("openServicesDropdown") {
            beforeEach {
                subject?.openServicesDropdown(viewModel: DropdownViewModel(screenTitle: "Commander",
                                                                           searchPlaceholderTitle: "Keen",
                                                                           attributes: [],
                                                                           buttonAction: nil, featureFlags: MockFeatureFlags()))
            }
            
            it("should push the view") {
                expect(navigationSubject?.pushWasCalled) == true
            }
            
            it("should push the correct view type") {
                expect(navigationSubject?.viewControllers[1] is DropdownViewController) == true
            }
        }
        
        describe("openEditLocation") {
            beforeEach {
                let mode = EditLocationMode.editUserLocation
                let place: Place = Place.init(placeId: String.makeRandom(), placeResumedData: String.makeRandom())
                subject?.openEditLocation(mode: mode,
                                          initialPlace:place,
                                          distanceRadius: nil,
                                          locationDelegate: self)
            }
            
            it("should push the view") {
                expect(navigationSubject?.pushWasCalled) == true
            }
            
            it("should push the correct view type") {
                expect(navigationSubject?.viewControllers[1] is EditLocationViewController) == true
            }
        }
        
        describe("openCarAttributeSelection") {
            beforeEach {
                subject?.openCarAttributeSelection(
                    withViewModel: CarAttributeSelectionViewModel(
                        yearsList: [], selectedYear: nil))
            }
            
            it("should push the view") {
                expect(navigationSubject?.pushWasCalled) == true
            }
            
            it("should push the correct view type") {
                expect(navigationSubject?.viewControllers[1] is CarAttributeSelectionViewController) == true
            }
        }
    }
}

extension FiltersModalWireframeSpec: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {}
}
