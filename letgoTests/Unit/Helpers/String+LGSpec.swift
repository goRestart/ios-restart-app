//
//  String+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 13/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class StringLGSpec: QuickSpec {
    override func spec() {
        var sut: String!

        describe("String + LG methods") {
            context("hasEmojis") {
                describe("contains unicodes but not emojis") {
                    beforeEach {
                        sut = "abz12309ASDFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦"
                    }
                    it("Doesn't detect any emoji") {
                        expect(sut.hasEmojis()) == false
                    }
                }
                describe("contains unicodes with emojis") {
                    beforeEach {
                        sut = "abz123🇹🇬6️⃣09AS👍DFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦✍🏿"
                    }
                    it("Detects emojis") {
                        expect(sut.hasEmojis()) == true
                    }
                }
            }
            context("stringByRemovingEmoji") {
                var withoutEmojis: String!
                describe("contains unicodes but not emojis") {
                    beforeEach {
                        sut = "abz12309ASDFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦"
                        withoutEmojis = sut.stringByRemovingEmoji()
                    }
                    it("leaves string as it is") {
                        expect(sut) == withoutEmojis
                    }
                }
                describe("contains unicodes with emojis") {
                    beforeEach {
                        sut = "abz123🇹🇬6️⃣09AS👍DFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦✍🏿"
                        withoutEmojis = sut.stringByRemovingEmoji()
                    }
                    it("removes emojis from the string") {
                        expect(withoutEmojis) == "abz12309ASDFѶڅ ࠄDਇቔḶ₸⍓♶㈶힘𐭄AS𓁦"
                    }
                }
            }
            context("isEmail") {
                describe("correct email") {
                    beforeEach {
                        sut = "ajan@pitican.com"
                    }
                    it("returns true") {
                        expect(sut.isEmail()) == true
                    }
                }
                describe("wrong email , instead of . ") {
                    beforeEach {
                        sut = "ajan@pitica,com"
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
                describe("wrong email no @ ") {
                    beforeEach {
                        sut = "ajan[at]pitican.com"
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
                describe("wrong email nothing after .") {
                    beforeEach {
                        sut = "ajan@pitican."
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
                describe("wrong email nothing before @") {
                    beforeEach {
                        sut = "@pitican.com"
                    }
                    it("returns false") {
                        expect(sut.isEmail()) == false
                    }
                }
            }
            context("isValidLengthPrice") {
                describe("correct number") {
                    beforeEach {
                        sut = "999,7"
                    }
                    it("accepts separator spanish locale (comma separator required) - returns true") {
                        expect(sut.isValidLengthPrice(true, locale: NSLocale(localeIdentifier: "es_ES") as Locale)) == true
                    }
                    it("accepts separator US locale (point separator required) - returns false") {
                        expect(sut.isValidLengthPrice(true, locale: NSLocale(localeIdentifier: "us_US") as Locale)) == false
                    }
                    it("does not accept separator - returns false") {
                        expect(sut.isValidLengthPrice(false)) == false
                    }
                }
                describe("not a number") {
                    beforeEach {
                        sut = "holaquetal"
                    }
                    it("returns false") {
                        expect(sut.isValidLengthPrice(true)) == false
                    }
                }
                describe("too big number") {
                    beforeEach {
                        sut = "1000000000"
                    }
                    it("returns false") {
                        expect(sut.isValidLengthPrice(true)) == false
                    }
                }
                describe("too much decimals") {
                    beforeEach {
                        sut = "100,888"
                    }
                    it("returns false") {
                        expect(sut.isValidLengthPrice(true)) == false
                    }
                }
            }
            context("toNameReduced") {
                describe("less than reduction size") {
                    beforeEach {
                        sut = "Eli Kohen".toNameReduced(maxChars: 12)
                    }
                    it("remains the same") {
                        expect(sut) == "Eli Kohen"
                    }
                }
                describe("First surname exceeds reduction size") {
                    beforeEach {
                        sut = "Albert Hernández".toNameReduced(maxChars: 12)
                    }
                    it("Reduces surname to first word") {
                        expect(sut) == "Albert H."
                    }
                }
                describe("First word exceeds reduction size") {
                    beforeEach {
                        sut = "AlbertHernándezTojunto".toNameReduced(maxChars: 12)
                    }
                    it("Just crops the first word") {
                        expect(sut) == "AlbertHernán."
                    }
                }
                describe("Second surname exceeds reduction size") {
                    beforeEach {
                        sut = "Eli Kohen Gómez".toNameReduced(maxChars: 12)
                    }
                    it("Reduces second surname to first word") {
                        expect(sut) == "Eli Kohen G."
                    }
                }
            }
            context("contains letgo") {
                it("returns false if does not contain letgo") {
                    expect("doesnotcontainit".containsLetgo()) == false
                }
                it("returns true if contains letgo") {
                    expect("letgo".containsLetgo()) == true
                }
                it("returns true if contains letgo uppercase") {
                    expect("LETGO".containsLetgo()) == true
                }
                it("returns true if contains ietgo") {
                    expect("ietgo sound like russian".containsLetgo()) == true
                }
                it("returns true if contains ietgo") {
                    expect("should not write ietgo".containsLetgo()) == true
                }
                it("returns true if contains ietg0") {
                    expect("ietg0 sounds super hackish".containsLetgo()) == true
                }
                it("returns true if contains let go") {
                    expect("let go is cool".containsLetgo()) == true
                }
                it("returns true if contains iet go") {
                    expect("iet go is cool".containsLetgo()) == true
                }
                it("returns true if contains let g0") {
                    expect("i work at let g0".containsLetgo()) == true
                }
                it("returns true if contains iet g0") {
                    expect("perhaps iet g0 is worth to publish".containsLetgo()) == true
                }
            }
        }
    }
}

