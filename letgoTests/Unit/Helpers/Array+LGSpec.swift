@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import LGComponents

final class ArrayExtensionLGSpec: QuickSpec {
    
    override func spec() {
        describe("Insert New Int List at positions") {
            var sut: [Int]!
            
            context("Insert new lists")  {
                
                let positions = [0, 3]
                let newList = [100, 101]
                
                beforeEach {
                    sut = [1, 2, 3, 4, 5, 6]
                }
                
                it("should insert list in correct positions") {
                    expect(sut.insert(newList: newList, at: positions)) == [100, 1, 2, 3, 101, 4, 5, 6]
                }
            }
            
            context("Insert empty list")  {
                
                let positions: [Int] = []
                let newList: [Int]  = []
                
                beforeEach {
                    sut = [1, 2, 3, 4, 5, 6]
                }
                
                it("should have the original array") {
                    expect(sut.insert(newList: newList, at: positions)) == [1, 2, 3, 4, 5, 6]
                }
            }
            
            context("Insert list to wrong position") {
                let positions: [Int] = [0, 7]
                let newList: [Int]  = [100, 101]
                
                beforeEach {
                    sut = [1, 2, 3, 4, 5, 6]
                }
                
                it("should only insert the correct one") {
                    expect(sut.insert(newList: newList, at: positions)) == [100, 1, 2, 3, 4, 5, 6]
                }
            }
            
            context("more items to insert than the available position") {
                
                let positions: [Int] = [0, 1]
                let newList: [Int]  = [100, 101, 102]
                
                beforeEach {
                    sut = [1, 2, 3, 4, 5, 6]
                }
                
                it("should ignore the extra items") {
                    expect(sut.insert(newList: newList, at: positions)) == [100, 1, 101, 2, 3, 4, 5, 6]
                }
            }
        }
        
        describe("offset bounds of integer array by given value") {
            let sut = [50, 34, 192, 5004, 2]
            
            context("inputing 2 to offsetBounds function") {
                
                it("should yield an array of [0, 5006]") {
                    expect(sut.offsetBounds(by: 2)) == [0, 5006]
                }
            }
            
            context("inputing 0 to offsetBounds function") {
                
                it("should yield an array of [2, 5004]") {
                    expect(sut.offsetBounds(by: 0)) == [2, 5004]
                }
            }
            
            context("inputing 10 to offsetBounds function") {
                
                it("should yield an array of [-8, 5014]") {
                    expect(sut.offsetBounds(by: 10)) == [-8, 5014]
                }
            }
        }
    }
}
