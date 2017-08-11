//
//  LGSliderViewModel.swift
//  LetGo
//
//  Created by Nestor on 10/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class LGSliderViewModelSpec: QuickSpec {
    override func spec() {
        describe("LGSliderViewModelSpec") {
            var sut: LGSliderViewModel!
            describe("selectionLabelText") {
                context("no values selected") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return minimumAndMaximumValuesNotSelectedText") {
                        expect(sut.selectionLabelText()) == "minimumAndMaximumValuesNotSelectedText"
                    }
                }
                context("minimum value selected equals minimumValue") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: 5,
                                                maximumValueSelected: nil)
                    }
                    it("should return minimumAndMaximumValuesNotSelectedText") {
                        expect(sut.selectionLabelText()) == "minimumAndMaximumValuesNotSelectedText"
                    }
                }
                context("minimum & maximum value selected equals minimumValue") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: 5,
                                                maximumValueSelected: 10)
                    }
                    it("should return minimumAndMaximumValuesNotSelectedText") {
                        expect(sut.selectionLabelText()) == "minimumAndMaximumValuesNotSelectedText"
                    }
                }
                context("minimum value selected and maximum nil") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: 7,
                                                maximumValueSelected: nil)
                    }
                    it("should return the combination minSelected - maxText") {
                        expect(sut.selectionLabelText()) == "7 - maximumValueNotSelectedText"
                    }
                }
                context("minimum value selected and maximum equal maximumValue") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: 7,
                                                maximumValueSelected: 10)
                    }
                    it("should return the combination minSelected - maxText") {
                        expect(sut.selectionLabelText()) == "7 - maximumValueNotSelectedText"
                    }
                }
                context("maximum value selected minimum value selected equals nil") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: 9)
                    }
                    it("should return the combination minText - maxSelected") {
                        expect(sut.selectionLabelText()) == "minimumValueNotSelectedText - 9"
                    }
                }
                context("maximum value selected minimum value selected equals minimumValue") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "title",
                                                minimumValueNotSelectedText: "minimumValueNotSelectedText",
                                                maximumValueNotSelectedText: "maximumValueNotSelectedText",
                                                minimumAndMaximumValuesNotSelectedText: "minimumAndMaximumValuesNotSelectedText",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: 5,
                                                maximumValueSelected: 9)
                    }
                    it("should return the combination minText - maxSelected") {
                        expect(sut.selectionLabelText()) == "minimumValueNotSelectedText - 9"
                    }
                }
            }
            describe("value:forConstant:minimumConstant:maximumConstant") {
                context("constant in mid range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the mid value") {
                        expect(sut.value(forConstant: 150, minimumConstant: 100, maximumConstant: 200)) == 8
                    }
                }
                context("constant at the end of range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the higher value") {
                        expect(sut.value(forConstant: 200, minimumConstant: 100, maximumConstant: 200)) == 10
                    }
                }
                context("constant higher than range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the higher value") {
                        expect(sut.value(forConstant: 300, minimumConstant: 100, maximumConstant: 200)) == 10
                    }
                }
                context("constant at the beginning of range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the lowest value") {
                        expect(sut.value(forConstant: 100, minimumConstant: 100, maximumConstant: 200)) == 5
                    }
                }
                context("constant lower than range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 5,
                                                maximumValue: 10,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the higher value") {
                        expect(sut.value(forConstant: 0, minimumConstant: 100, maximumConstant: 200)) == 5
                    }
                }
            }
            describe("constant:forConstant:minimumConstant:maximumConstant") {
                context("value in mid range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 10,
                                                maximumValue: 20,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the mid constant") {
                        expect(sut.constant(forValue: 15, minimumConstant: 100, maximumConstant: 200)) == 150
                    }
                }
                context("value at the end of range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 10,
                                                maximumValue: 20,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the higher constant") {
                        expect(sut.constant(forValue: 20, minimumConstant: 100, maximumConstant: 200)) == 200
                    }
                }
                context("value higher than range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 10,
                                                maximumValue: 20,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the higher constant") {
                        expect(sut.constant(forValue: 30, minimumConstant: 100, maximumConstant: 200)) == 200
                    }
                }
                context("value at the beginning of range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                    minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 10,
                                                maximumValue: 20,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the lowest constant") {
                        expect(sut.constant(forValue: 10, minimumConstant: 100, maximumConstant: 200)) == 100
                    }
                }
                context("value lower than range") {
                    beforeEach {
                        sut = LGSliderViewModel(title: "",
                                                minimumValueNotSelectedText: "",
                                                maximumValueNotSelectedText: "",
                                                minimumAndMaximumValuesNotSelectedText: "",
                                                minimumValue: 10,
                                                maximumValue: 20,
                                                minimumValueSelected: nil,
                                                maximumValueSelected: nil)
                    }
                    it("should return the higher constant") {
                        expect(sut.constant(forValue: 0, minimumConstant: 100, maximumConstant: 200)) == 100
                    }
                }

            }
        }
    }
}
