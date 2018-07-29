import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode


final class DropdownSectionSpec: QuickSpec {
    
    override func spec() {
        
        let mockHeader = DropdownCellViewModel(withContent: DropdownCellContent(type: .header,
                                                                                title: "header",
                                                                                id: "123"),
                                               state: .semiSelected)
        let mockHeader2 = DropdownCellViewModel(withContent: DropdownCellContent(type: .header,
                                                                                 title: "header2",
                                                                                 id: "321"),
                                                state: .deselected)
        
        let mockItems = [DropdownCellViewModel(withContent: DropdownCellContent(type: .item(featured: true),
                                                                                title: "item1", id: "111"),
                                               state: .selected),
                         DropdownCellViewModel(withContent: DropdownCellContent(type: .item(featured: false),
                                                                                title: "item2", id: "222"),
                                               state: .deselected)]
        let mockItems2 = [DropdownCellViewModel(withContent: DropdownCellContent(type: .item(featured: true),
                                                                                 title: "item3", id: "333"),
                                                state: .deselected),
                          DropdownCellViewModel(withContent: DropdownCellContent(type: .item(featured: false),
                                                                                 title: "item4", id: "444"),
                                                state: .deselected)]
        var sut: DropdownSectionViewModel!
        var sutSections: [DropdownSectionViewModel]!
        
        describe("DropdownSectionSpec") {
            
            beforeEach {
                sut = DropdownSectionViewModel(withHeader: mockHeader,
                                      items: mockItems,
                                      isExpanded: false,
                                      isShowingAll: false)
                sutSections = [DropdownSectionViewModel(withHeader: mockHeader,
                                               items: mockItems,
                                               isExpanded: false,
                                               isShowingAll: false),
                               DropdownSectionViewModel(withHeader: mockHeader2,
                                               items: mockItems2,
                                               isExpanded: false,
                                               isShowingAll: false)]
            }
            
            context("deselectAllItems") {
                beforeEach {
                    sut.item(forIndex: 0)?.update(withState: .selected)
                    sut.deselectAllItems()
                }
                it("all items must be deselected") {
                    expect(sut.selectedItems).to(beNil())
                }
            }
            context("selectHeader") {
                beforeEach {
                    sut.selectHeader()
                }
                it("header must be selected") {
                    expect(sut.selectedItems?.selectedHeaderId).to(equal("123"))
                }
                it("selected items must be empty") {
                    expect(sut.selectedItems?.selectedItemIds).to(equal([]))
                }
            }
            context("absorb") {
                beforeEach {
                    sut.deselectAllItems()
                    sut.setupSectionAsSelected(withSelectedItemIds: ["111"])
                    sut.toggleExpansionState(forId: "123")
                }
                it("header is semiselected") {
                    expect(sut.item(forIndex: 0)?.state).to(equal(.semiSelected))
                }
                it("first item is selected") {
                    expect(sut.item(forIndex: 1)?.state).to(equal(.selected))
                }
            }
            context("toggleExpansionState") {
                beforeEach {
                    sut.toggleExpansionState(forId: "123")
                }
                it("is expanded") {
                    expect(sut.isExpanded).to(equal(true))
                }
            }
            
            //  DropdownSection Collection
            
            context("dropdownSection collection") {
                context("toggleExpansionState") {
                    beforeEach {
                        sutSections.toggleExpansionState(forId: "123")
                    }
                    it("is expanded") {
                        expect(sutSections.expansionState(forId: "123")).to(equal(true))
                    }
                }
                context("selectSection") {
                    beforeEach {
                        sutSections.first?.isExpanded = true
                        sutSections.first?.isShowingAll = true
                        sutSections.selectSection(withHeaderId: "123")
                    }
                    it("header is selected") {
                        expect(sutSections?.first?.item(forIndex: 0)?.state).to(equal(.selected))
                    }
                    it("first item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 1)?.state).to(equal(.deselected))
                    }
                    it("second item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 2)?.state).to(equal(.deselected))
                    }
                }
                context("deselectSection") {
                    beforeEach {
                        sutSections.first?.isExpanded = true
                        sutSections.first?.isShowingAll = true
                        sutSections.deselectSection(withHeaderId: "123")
                    }
                    it("header is deselected") {
                        expect(sutSections?.first?.item(forIndex: 0)?.state).to(equal(.deselected))
                    }
                    it("first item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 1)?.state).to(equal(.deselected))
                    }
                    it("second item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 2)?.state).to(equal(.deselected))
                    }
                }
                
                context("deselectItem") {
                    beforeEach {
                        sutSections.first?.isExpanded = true
                        sutSections.first?.isShowingAll = true
                        sutSections.deselectItem(withItemId: "111")
                    }
                    it("header is deselected") {
                        expect(sutSections?.first?.item(forIndex: 0)?.state).to(equal(.deselected))
                    }
                    it("first item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 1)?.state).to(equal(.deselected))
                    }
                    it("second item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 2)?.state).to(equal(.deselected))
                    }
                }
                context("deselectAllItems") {
                    beforeEach {
                        for section in sutSections {
                            section.isExpanded = true
                            section.isShowingAll = true
                        }
                        sutSections.deselectAllItems()
                    }
                    it("first section - header is deselected") {
                        expect(sutSections?.first?.item(forIndex: 0)?.state).to(equal(.deselected))
                    }
                    it("first section - first item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 1)?.state).to(equal(.deselected))
                    }
                    it("first section - second item is deselected") {
                        expect(sutSections?.first?.item(forIndex: 2)?.state).to(equal(.deselected))
                    }
                    it("second section - header is deselected") {
                        expect(sutSections?[safeAt:1]?.item(forIndex: 0)?.state).to(equal(.deselected))
                    }
                    it("second section - first item is deselected") {
                        expect(sutSections?[safeAt:1]?.item(forIndex: 1)?.state).to(equal(.deselected))
                    }
                    it("second section - second item is deselected") {
                        expect(sutSections?[safeAt:1]?.item(forIndex: 2)?.state).to(equal(.deselected))
                    }
                }
                
            }
        }
    }
}

