import Quick
import Nimble
@testable import LetGoGodMode

final class FiltersModalRouterSpec: QuickSpec {
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
        
        var subject: FiltersModalRouter?
        var navigationSubject: MockNavigationController?
        var controller: MockViewController?
        
        beforeEach {
            controller = MockViewController(nibName: nil, bundle: nil)
            navigationSubject = MockNavigationController(rootViewController: controller!)
            subject = FiltersModalRouter(controller: controller!, navigationController: navigationSubject!)
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
                                                                           buttonAction: nil))
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
                subject?.openEditLocation(withViewModel: EditLocationViewModel(mode: .editUserLocation))
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
                expect(navigationSubject?.viewControllers[1] is TaxonomiesViewController) == true
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
                expect(navigationSubject?.viewControllers[1] is TaxonomiesViewController) == true
            }
        }
    }
}
