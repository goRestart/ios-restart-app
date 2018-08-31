import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode

final class FiltersStandardWireframeSpec: QuickSpec {
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
        
        var subject: FiltersStandardWireframe?
        var navigationSubject: MockNavigationController?
        
        beforeEach {
            navigationSubject = MockNavigationController()
            subject = FiltersStandardWireframe(nc: navigationSubject!)
        }
        
        describe("closeFilters") {
            beforeEach {
                subject?.closeFilters()
            }
            
            it("should dismiss the view controller") {
                expect(navigationSubject?.popWasCalled) == true
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
                expect(navigationSubject?.viewControllers[0] is DropdownViewController) == true
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
                expect(navigationSubject?.viewControllers[0] is EditLocationViewController) == true
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
                expect(navigationSubject?.viewControllers[0] is CarAttributeSelectionViewController) == true
            }
        }
    }
}

extension FiltersStandardWireframeSpec: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {}
}
