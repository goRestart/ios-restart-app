import Quick
import Nimble
@testable import LetGoGodMode

class ScrollingPageControlIndexCalculatorSpec: QuickSpec {
    
    override func spec() {
        describe("test scrolling downards") {
            context("selectedIndex is equal to directionChangeSourcePage") {
                let sut = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                              tinyIndexOffset: 2,
                                                              selectedIndex: 0,
                                                              currentScrollDirection: .down,
                                                              directionChangeSourcePage: 0,
                                                              adjacentIndexThreshold: 2)
                
                it("adjacent indexes should be 1 and 2") {
                    expect(sut.adjacentIndexes) == [1, 2]
                }
                
                it("small indexes should be 3 and 0") {
                    expect(sut.smallIndexes) == [0, 3]
                }
                
                it("tiny indexes should be 4 and -1") {
                    expect(sut.tinyIndexes) == [-1, 4]
                }
            }
            
            context("selectedIndex is equal to directionChangeSourcePage+1") {
                let sut = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                              tinyIndexOffset: 2,
                                                              selectedIndex: 1,
                                                              currentScrollDirection: .down,
                                                              directionChangeSourcePage: 0,
                                                              adjacentIndexThreshold: 2)
                
                it("adjacent indexes should be 0 and 2") {
                    expect(sut.adjacentIndexes) == [0, 2]
                }
                
                it("small indexes should be 3 and -1") {
                    expect(sut.smallIndexes) == [-1, 3]
                }
                
                it("tiny indexes should be 4 and -2") {
                    expect(sut.tinyIndexes) == [-2, 4]
                }
            }
            
            context("directionChangeSourcePage <= selectedIndex") {
                let sut = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                              tinyIndexOffset: 2,
                                                              selectedIndex: 10,
                                                              currentScrollDirection: .down,
                                                              directionChangeSourcePage: 0,
                                                              adjacentIndexThreshold: 2)
                
                it("adjacent indexes should be 8 and 9") {
                    expect(sut.adjacentIndexes) == [8, 9, 10]
                }
                
                it("small indexes should be 7 and 11") {
                    expect(sut.smallIndexes) == [7, 11]
                }
                
                it("tiny indexes should be 6 and 12") {
                    expect(sut.tinyIndexes) == [6, 12]
                }
            }
        }
        
        describe("test scrolling upwards") {
            context("selectedIndex is equal to directionChangeSourcePage") {
                let sut = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                              tinyIndexOffset: 2,
                                                              selectedIndex: 7,
                                                              currentScrollDirection: .up,
                                                              directionChangeSourcePage: 7,
                                                              adjacentIndexThreshold: 2)
                
                it("adjacent indexes should be 6 and 5") {
                    expect(sut.adjacentIndexes) == [6, 5]
                }
                
                it("small indexes should be 4 and 7") {
                    expect(sut.smallIndexes) == [4, 7]
                }
                
                it("tiny indexes should be 3 and 8") {
                    expect(sut.tinyIndexes) == [3, 8]
                }
            }
            
            context("selectedIndex is equal to directionChangeSourcePage-1") {
                let sut = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                              tinyIndexOffset: 2,
                                                              selectedIndex: 6,
                                                              currentScrollDirection: .up,
                                                              directionChangeSourcePage: 7,
                                                              adjacentIndexThreshold: 2)
                
                it("adjacent indexes should be 5 and 7") {
                    expect(sut.adjacentIndexes) == [5, 7]
                }
                
                it("small indexes should be 4 and 8") {
                    expect(sut.smallIndexes) == [4, 8]
                }
                
                it("tiny indexes should be 3 and 9") {
                    expect(sut.tinyIndexes) == [3, 9]
                }
            }
            
            context("directionChangeSourcePage > selectedIndex") {
                let sut = ScrollingPageControlIndexCalculator(smallIndexOffset: 1,
                                                              tinyIndexOffset: 2,
                                                              selectedIndex: 4,
                                                              currentScrollDirection: .up,
                                                              directionChangeSourcePage: 10,
                                                              adjacentIndexThreshold: 2)
                
                it("adjacent indexes should be 4, 5 and 6") {
                    expect(sut.adjacentIndexes) == [4, 5, 6]
                }
                
                it("small indexes should be 3 and 7") {
                    expect(sut.smallIndexes) == [3, 7]
                }
                
                it("tiny indexes should be 2 and 8") {
                    expect(sut.tinyIndexes) == [2, 8]
                }
            }
        }
        
    }
}
