
@testable import LetGoGodMode
import Quick
import Nimble

class FormattedUnitRangeSpec: QuickSpec {
    
    override func spec() {
        
        var sut: FormattedUnitRange!
        var minValue: Int!
        var maxValue: Int!
        var unitSuffix: String!
        var numberFormatter: NumberFormatter!
        
        describe("test FormattedUnitRange") {
            
            beforeEach {
                
                minValue = Int.makeRandom()
                maxValue = Int.makeRandom()
                unitSuffix = String.makeRandom()
                numberFormatter = NumberFormatter.newMileageNumberFormatter()
                
                sut = FormattedUnitRange(minimumValue: minValue,
                                         maximumValue: maxValue,
                                         unitSuffix: unitSuffix,
                                         numberFormatter: numberFormatter)
            }
            
            context("test output string formatting") {
                var expectedValue: String!

                beforeEach {
                    let minValueString = numberFormatter.string(from: NSNumber(value: minValue))!
                    let maxValueString = numberFormatter.string(from: NSNumber(value: maxValue))!
                    
                    expectedValue = "\(minValueString) - \(maxValueString) \(unitSuffix!)"
                }
                
                it("should have a valid formatted unit range string") {
                    
                    
                    expect(sut.toString()).to(equal(expectedValue))
                }
            }
        }
    }
}
