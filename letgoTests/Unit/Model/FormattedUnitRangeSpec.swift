
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
            }
            
            context("test output string formatting - bounded upper value") {
                
                var expectedValue: String!

                beforeEach {
                    let minValueString = numberFormatter.string(from: NSNumber(value: minValue))!
                    let maxValueString = numberFormatter.string(from: NSNumber(value: maxValue))!
                    
                    expectedValue = "\(minValueString) - \(maxValueString) \(unitSuffix!)"
                    
                    sut = FormattedUnitRange(minimumValue: minValue,
                                             maximumValue: maxValue,
                                             unitSuffix: unitSuffix,
                                             numberFormatter: numberFormatter,
                                             isUnboundedUpperValue: false)
                }
                
                it("should have a valid formatted unit range string") {
                    expect(sut.toString()).to(equal(expectedValue))
                }
            }
            
            context("test output string formatting - unbounded upper value") {
                
                var expectedValue: String!
                
                beforeEach {
                    let minValueString = numberFormatter.string(from: NSNumber(value: minValue))!
                    let maxValueString = numberFormatter.string(from: NSNumber(value: maxValue))!
                    
                    expectedValue = "\(minValueString) - \(maxValueString)+ \(unitSuffix!)"
                    
                    sut = FormattedUnitRange(minimumValue: minValue,
                                             maximumValue: maxValue,
                                             unitSuffix: unitSuffix,
                                             numberFormatter: numberFormatter,
                                             isUnboundedUpperValue: true)
                }
                
                it("should have a valid formatted unit range string") {
                    expect(sut.toString()).to(equal(expectedValue))
                }
            }
        }
    }
}
