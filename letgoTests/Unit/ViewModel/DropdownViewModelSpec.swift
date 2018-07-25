
@testable import LetGoGodMode

import Quick
import Nimble
import LGCoreKit

class DropdownViewModelSpec: QuickSpec {
    
    override func spec() {
        var sut: DropdownViewModel!
        
        beforeEach {
            let dropdownSectionA = MockServiceType.makeMock().sectionRepresentable
            let dropdownSectionB = MockServiceType.makeMock().sectionRepresentable
            
            sut = DropdownViewModel(screenTitle: String.makeRandom(),
                                    searchPlaceholderTitle: String.makeRandom(),
                                    attributes: [dropdownSectionA, dropdownSectionB],
                                    buttonAction: nil)
        }

        context("test item selection") {
            
            context("header selection") {
                
                beforeEach {
                    sut.didSelectItem(atIndexPath: IndexPath(row: 0, section: 0))
                }
                
                it("on header selection, the section should be expanded") {
                    expect(sut.attributes.first!.isExpanded).to(beTrue())
                }
            }
            
            context("header reselection") {
                
                beforeEach {
                    sut.didSelectItem(atIndexPath: IndexPath(row: 0, section: 0))
                    sut.didSelectItem(atIndexPath: IndexPath(row: 0, section: 0))
                }
                
                it("on reselecting a header, the section should be contracted") {
                    expect(sut.attributes.first!.isExpanded).to(beFalse())
                }
            }
            
            context("item selection") {
                
                beforeEach {
                    sut.didSelectItem(atIndexPath: IndexPath(row: 1, section: 0))
                }
                
                it("on item selection, the item's state should be selected") {
                    if let item = sut.attributes[0].item(forIndex: 1)?.state {
                        expect(item).to(equal(DropdownCellState.selected))
                    }
                }
            }
        }
        
        context("test item deselection") {
            
            context("header deselection") {
                
                beforeEach {
                    sut.didDeselectItem(atIndexPath: IndexPath(row: 0, section: 0))
                }
                
                it("on header deselection, the section should be expanded") {
                    expect(sut.attributes.first!.isExpanded).to(beTrue())
                }
            }
            
            context("header re-deselection") {
                
                beforeEach {
                    sut.didDeselectItem(atIndexPath: IndexPath(row: 0, section: 0))
                    sut.didDeselectItem(atIndexPath: IndexPath(row: 0, section: 0))
                }
                
                it("on re-deselecting a header, the section should be contracted") {
                    expect(sut.attributes.first!.isExpanded).to(beFalse())
                }
            }
            
            context("item deselection") {

                beforeEach {
                    sut.didDeselectItem(atIndexPath: IndexPath(row: 1, section: 0))
                }
                
                it("on item deselection, the item's state should be deselected") {
                    if let item = sut.attributes[0].item(forIndex: 1)?.state {
                        expect(item).to(equal(DropdownCellState.deselected))
                    }
                }
            }
        }
        
        context("test toggle header selection") {
            
            context("header selection") {
                
                beforeEach {
                    sut.toggleHeaderSelection(atIndexPath: IndexPath(row: 0, section: 0))
                }
                
                it("header should be selected") {
                    expect(sut.attributes[0].item(forIndex: 0)?.state).to(equal(DropdownCellState.selected))
                }
                
                it("items should be selected") {
                    for i in 0...sut.attributes[0].count {
                        expect(sut.attributes[0].item(forIndex: i)?.state).to(equal(DropdownCellState.selected))
                    }
                }
            }
            
            context("header deselection") {

                beforeEach {
                    sut.toggleHeaderSelection(atIndexPath: IndexPath(row: 0, section: 0))
                    sut.toggleHeaderSelection(atIndexPath: IndexPath(row: 0, section: 0))
                }
                
                it("header should be deselected") {
                    expect(sut.attributes[0].item(forIndex: 0)?.state).to(equal(DropdownCellState.deselected))
                }
                
                it("items should be deselected") {
                    for i in 0...sut.attributes[0].count {
                        expect(sut.attributes[0].item(forIndex: i)?.state).to(equal(DropdownCellState.deselected))
                    }
                }
            }
        }
    }
}
