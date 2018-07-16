

@testable import LetGoGodMode
import Quick
import Nimble

class NumberFormatterLGSpec: QuickSpec {
    
    override func spec() {
        describe("testing mileage formatter") {
            
            context("mileage and unit supplied") {
                var formattedMileage: String?
                var value: Int?
                var unit: String?
                var numberFormatter: NumberFormatter?
                beforeEach {
                    numberFormatter = NumberFormatter.newMileageNumberFormatter()
                    value = Int.makeRandom()
                    unit = String.makeRandom()
                    formattedMileage = NumberFormatter.formattedMileage(forValue: value,
                                                                        distanceUnit: unit)
                }
                
                it("has a valid mileage string") {
                    let form = numberFormatter!.string(from: NSNumber(value: value!))!
                    let expectedString = "\(form) \(unit!)"
                    expect(formattedMileage).to(equal(expectedString))
                }
            }
            
            context("mileage supplied but no unit") {
                var formattedMileage: String?

                beforeEach {
                    let value = Int.makeRandom()
                    let unit: String? = nil
                    formattedMileage = NumberFormatter.formattedMileage(forValue: value,
                                                                            distanceUnit: unit)
                }
                
                it("does not have a valid mileage string") {
                    expect(formattedMileage).to(beNil())
                }
            }
            
            context("unit supplied but no mileage") {
                var formattedMileage: String?

                beforeEach {
                    let value: Int? = nil
                    let unit = String.makeRandom()
                    formattedMileage = NumberFormatter.formattedMileage(forValue: value,
                                                                            distanceUnit: unit)
                }
                
                it("does not have a valid mileage string") {
                    expect(formattedMileage).to(beNil())
                }
            }
        }
    }
}
