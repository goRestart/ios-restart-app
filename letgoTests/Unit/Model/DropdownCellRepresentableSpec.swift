import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode


final class DropdownCellRepresentableSpec: QuickSpec {
    
    override func spec() {
        let mockServiceTypes: [ServiceType] = MockServiceType.makeMocks(count: 5)
        let mockAllServicesSubtypes = mockServiceTypes.flatMap { $0.subTypes }
        let selectedType = mockServiceTypes.first
        let selectedSubtypes = [selectedType?.subTypes.first].compactMap { $0 }
        let mockServiceFilters = ServicesFilters(type: mockServiceTypes.first, subtypes: selectedSubtypes)
        
        var sutCellRepresentables: [DropdownCellRepresentable]!
        var sut: DropdownCellRepresentable!
        
        describe("DropdownCellRepresentableSpec") {
            context("ServiceType extension find all cellRepresentables") {
                beforeEach {
                    sutCellRepresentables = mockServiceTypes.cellRepresentables
                }
                it("all cellRepresentable are in") {
                    let servicesSubtypesAndTypesCount = mockServiceTypes.count + mockAllServicesSubtypes.count
                    expect(sutCellRepresentables.count).to(equal(servicesSubtypesAndTypesCount))
                }
            }
            context("update withState") {
                beforeEach {
                    let content = DropdownCellContent(type: .header, title: "test1", id: "123")
                    sut = DropdownCellViewModel(withContent: content, state: .disabled)
                }
                it("is updated") {
                    sut.update(withState: .selected)
                    expect(sut.state).to(equal(.selected))
                }
            }
            context("updatedCellRepresentables with ServicesFilters") {
                beforeEach {
                    sutCellRepresentables = mockServiceTypes.cellRepresentables
                        .updatedCellRepresentables(withServicesFilters: mockServiceFilters)
                }
                it("first header is semiselected") {
                    expect(sutCellRepresentables.first?.state).to(equal(.semiSelected))
                }
                it("first subtype is selected") {
                    expect(sutCellRepresentables[safeAt: 1]?.state).to(equal(.selected))
                }
            }
        }
    }
}
