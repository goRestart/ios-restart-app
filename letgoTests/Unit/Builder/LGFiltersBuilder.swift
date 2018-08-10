import Quick
import Nimble
@testable import LetGoGodMode

final class LGFiltersBuilderSpec: QuickSpec {
    override func spec() {
        var subject: LGFiltersBuilder?
        
        context("when the mode is standard") {
            class NavigationController: UINavigationController {}
            
            beforeEach {
                subject = LGFiltersBuilder.standard(navigationController: NavigationController())
            }
            
            describe("buildFilters") {
                var controller: FiltersViewController?
                
                beforeEach {
                    controller = subject?.buildFilters(
                        filters: ListingFilters(), dataDelegate: nil
                    )
                }
                
                it("should has a correct view controller") {
                    expect(controller).toNot(beNil())
                }
            }
        }
        
        context("when the mode is modal") {
            beforeEach {
                subject = LGFiltersBuilder.modal
            }
            
            describe("buildChangePassword") {
                var controller: FiltersViewController?
                
                beforeEach {
                    controller = subject?.buildFilters(
                        filters: ListingFilters(), dataDelegate: nil)
                }
                
                it("should has a correct view controller") {
                    expect(controller).toNot(beNil())
                }
            }
        }
    }
}
