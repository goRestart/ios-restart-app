import Quick
import Nimble
@testable import LetGoGodMode

final class FiltersStandardRouterSpec: QuickSpec {
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
        
        var subject: FiltersStandardRouter?
        var navigationSubject: MockNavigationController?
        
        beforeEach {
            navigationSubject = MockNavigationController()
            subject = FiltersStandardRouter(controller: navigationSubject!)
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
                                                                           buttonAction: nil))
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
                subject?.openEditLocation(withViewModel: EditLocationViewModel(mode: .editUserLocation))
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
        
        describe("openTaxonomyList") {
            beforeEach {
                subject?.openTaxonomyList(withViewModel: TaxonomiesViewModel(
                    taxonomies: [],
                    taxonomySelected: nil,
                    taxonomyChildSelected: nil,
                    source: .chat
                ))
            }
            
            it("should push the view") {
                expect(navigationSubject?.pushWasCalled) == true
            }
            
            it("should push the correct view type") {
                expect(navigationSubject?.viewControllers[0] is TaxonomiesViewController) == true
            }
        }
        
        describe("openTaxonomyList") {
            beforeEach {
                subject?.openTaxonomyList(withViewModel: TaxonomiesViewModel(
                    taxonomies: [],
                    taxonomySelected: nil,
                    taxonomyChildSelected: nil,
                    source: .chat
                ))
            }
            
            it("should push the view") {
                expect(navigationSubject?.pushWasCalled) == true
            }
            
            it("should push the correct view type") {
                expect(navigationSubject?.viewControllers[0] is TaxonomiesViewController) == true
            }
        }
    }
}
