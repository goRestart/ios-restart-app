//
//  CarAttributes+LGSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

class CarAttributesLGSpec: QuickSpec {
    override func spec() {
        var carAttributes: CarAttributes!
        var sut: String!
        
        
        describe("Generate car title") {
            context("with no data on attributes") {
                beforeEach {
                    carAttributes = CarAttributes.emptyCarAttributes()
                    sut = carAttributes.generatedTitle
                }
                it ("returns empty title") {
                    expect(sut) == ""
                }
                context("attributes with all attributes") {
                    beforeEach {
                        carAttributes = CarAttributes(makeId: "123", make: "Audi", modelId: "321", model: "A4", year: 2017)
                        sut = carAttributes.generatedTitle
                    }
                    it ("result should equal: Audi - A4 - 2017") {
                        expect(sut) == "Audi - A4 - 2017"
                    }
                }
                context("attributes with make only") {
                    beforeEach {
                        carAttributes = CarAttributes(makeId: "123", make: "Audi", modelId: nil, model: nil, year: nil)
                        sut = carAttributes.generatedTitle
                    }
                    it ("result should equal: Audi") {
                        expect(sut) == "Audi"
                    }
                }
                context("attributes with year only") {
                    beforeEach {
                        carAttributes = CarAttributes(makeId: nil, make: nil, modelId: nil, model: nil, year: 2017)
                        sut = carAttributes.generatedTitle
                    }
                    it ("result should equal: 2017") {
                        expect(sut) == "2017"
                    }
                }
                context("attributes with model and year") {
                    beforeEach {
                        carAttributes = CarAttributes(makeId: nil, make: nil, modelId: nil, model: "A4", year: 2017)
                        sut = carAttributes.generatedTitle
                    }
                    it ("result should equal: A4 - 2017") {
                        expect(sut) == "A4 - 2017"
                    }
                }
                context("attributes with make and model") {
                    beforeEach {
                        carAttributes = CarAttributes(makeId: "124", make: "Audi", modelId: "123", model: "A4", year: nil)
                        sut = carAttributes.generatedTitle
                    }
                    it ("result should equal: Audi - A4") {
                        expect(sut) == "Audi - A4"
                    }
                }
            }
        }
    }
}
