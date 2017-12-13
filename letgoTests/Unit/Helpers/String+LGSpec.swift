//
//  String+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 13/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
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
            context("suggest email") {
                let domains = ["gmail.com", "yahoo.com", "hotmail.com", "aol.com", "icloud.com", "outlook.com",
                               "live.com", "comcast.com", "msn.com", "windowslive.com", "mynet.com", "yandex.com"]

                it("does not suggest when no @ sign is typed") {
                    expect("alb".suggestEmail(domains: domains)).to(beNil())
                }
                it("does not suggest if no domain letter is typed after @ sign") {
                    expect("albert@".suggestEmail(domains: domains)).to(beNil())
                }
                it("does not suggest if domain prefix doesnt not match any of the given domains") {
                    expect("albert@x".suggestEmail(domains: domains)).to(beNil())
                }
                it("does not suggest if domain doesnt not match any of the given domains") {
                    expect("albert@gmail.coma".suggestEmail(domains: domains)).to(beNil())
                }
                it("suggests based on domains parameter order") {
                    expect("albert@m".suggestEmail(domains: domains)) == "albert@msn.com"
                }
                it("suggests based on domains parameter order") {
                    expect("albert@my".suggestEmail(domains: domains)) == "albert@mynet.com"
                }
                it("removes suggestion if space is pressed") {
                    expect("albert@my ".suggestEmail(domains: domains)).to(beNil())
                }
            }
            context("stringByReplacingFirstOccurrence") {
                it("does nothing if doesn't find any occurrence") {
                    expect("a vocal is a letter".stringByReplacingFirstOccurrence(of: "the", with: "")) == "a vocal is a letter"
                }
                it("replaces the only occurence when having just one") {
                    expect("vocals are letters".stringByReplacingFirstOccurrence(of: "are", with: "and")) == "vocals and letters"
                }
                it("replaces only the first occurence when having two instances") {
                    expect("a vocal is a letter".stringByReplacingFirstOccurrence(of: "a", with: "this")) == "this vocal is a letter"
                }
                it("takes in account options when used") {
                    expect("A vocal is A letter".stringByReplacingFirstOccurrence(of: "a", with: "this",
                                                                                  options: .caseInsensitive)) == "this vocal is A letter"
                }
            }
            context("makeUsernameFromEmail") {
                it("returns nil if the string is not an email") {
                    expect("albert".makeUsernameFromEmail()).to(beNil())
                }
                it("returns the capitalized name if the email username is just the name") {
                    expect("albert@letgo.com".makeUsernameFromEmail()) == "Albert"
                }
                it("returns the capitalized name & surname if the email username has them splitted with a dot") {
                    expect("albert.hernandez@letgo.com".makeUsernameFromEmail()) == "Albert Hernandez"
                }
                it("returns the capitalized name & surname if the email username has them splitted with a dash") {
                    expect("albert-hernandez@letgo.com".makeUsernameFromEmail()) == "Albert Hernandez"
                }
                it("returns the capitalized name & surname if the email username has them splitted with an underscore") {
                    expect("albert_hernandez@letgo.com".makeUsernameFromEmail()) == "Albert Hernandez"
                }
                it("ignores what's behind of a plus sign") {
                    expect("albert.hernandez+scam.i.love@letgo.com".makeUsernameFromEmail()) == "Albert Hernandez"
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
            context("removeHTMLTags") {
                it("does nothing if doesn't find any html tag") {
                    expect("a vocal is a letter".ignoreHTMLTags) == "a vocal is a letter"
                }
                it("removes tags and returns content") {
                    expect("a vocal <b>is</b> a letter".ignoreHTMLTags) == "a vocal is a letter"
                }
                it("removes simple tag and returns content") {
                    expect("a vocal <b>is a letter".ignoreHTMLTags) == "a vocal is a letter"
                }
                it("removes tags from begin and end of the string and returns content") {
                    expect("<b>a vocal is a letter</html>".ignoreHTMLTags) == "a vocal is a letter"
                }
            }
            describe("clipMoreThan: wordCount") {
                it("sentence with more than count returns clipped") {
                    expect("This is a sentence of seven words".clipMoreThan(wordCount: 4)) == "This is a sentence"
                }
                it("sentence with less than count returns string itself") {
                    expect("This is a sentence of seven words".clipMoreThan(wordCount: 9)) == "This is a sentence of seven words"
                }
                it("sentence with equal count returns string itself") {
                    expect("This is a sentence of seven words".clipMoreThan(wordCount: 7)) == "This is a sentence of seven words"
                }
                it("sentence with zero count returns empty") {
                    expect("This is a sentence of seven words".clipMoreThan(wordCount: 0)) == ""
                }
            }
            describe("trim(strings:separator:)") {
                it("trims the tags") {
                    expect("Hi. Bye.".trim(strings: ["Hi", "Bye"], separator: ".")) == ""
                }
                it("trims the tags and leave what user wrote ending w/o dot") {
                    expect("Hi. Bye. It was nice".trim(strings: ["Hi", "Bye"], separator: ".")) == "It was nice"
                }
                it("trims the tags and leave what user wrote ending with dot") {
                    expect("Hi. Bye. It was nice.".trim(strings: ["Hi", "Bye"], separator: ".")) == "It was nice."
                }
                it("trims the tags and leave what user wrote ending with dot & space") {
                    expect("Hi. Bye. It was nice. ".trim(strings: ["Hi", "Bye"], separator: ".")) == "It was nice."
                }
            }
            describe("make(tagsString:comment:)") {
                context("w/o comment") {
                    it("builds up a string with the given tags strings") {
                        expect(String.make(tagsString: ["ex1", "ex2"])) == "ex1. ex2"
                    }
                }
                context("with comment") {
                    it("builds up a string with the given tag strings and comment") {
                        expect(String.make(tagsString: ["ex1", "ex2"], comment: "append")) == "ex1. ex2. append"
                    }
                }
            }
            context("isOnlyDigits") {
                it ("returns true if only digits") {
                     expect("12345".isOnlyDigits) == true
                }
                it ("returns true if empty") {
                    expect("".isOnlyDigits) == true
                }
                it ("returns false if there's any non-digit - letters") {
                    expect("123AB".isOnlyDigits) == false
                }
                it ("returns false if there's any non-digit - punctuation") {
                    expect("123.5".isOnlyDigits) == false
                }
                it ("returns false if there's any non-digit - others") {
                    expect("123 123".isOnlyDigits) == false
                }
            }
        }
        
        describe("makeBold:ignoringText:font") {
            context("setBold:ignoreText:font") {
                var sut: String!
                var result: NSAttributedString!
                var ignoreText: String!
                var font: UIFont!
                var regularAttributes: [String : Any]!
                var boldAttributes: [String : Any]!
                
                context("with a valid font") {
                    context("ignoreText contained in string") {
                        beforeEach {
                            sut = "house for rent"
                            ignoreText = "hous"
                            font = UIFont.systemFont(ofSize: 15)
                            
                            result = sut.makeBold(ignoringText: ignoreText, font: font)
                            
                            regularAttributes = result.attributes(at: 0,
                                                                  longestEffectiveRange: nil,
                                                                  in: NSRange(location: 0, length: ignoreText.count))
                            
                            let boldStarIndex = ignoreText.count > 0 ? ignoreText.count + 1 : 0
                            let boldLength = result.string.count-ignoreText.count
                            boldAttributes = result.attributes(at: boldStarIndex,
                                                               longestEffectiveRange: nil,
                                                               in: NSRange(location: boldStarIndex, length: boldLength))
                        }
                        it("has the specified point size on regular attributes") {
                            expect((regularAttributes[NSFontAttributeName] as! UIFont).pointSize) == 15
                        }
                        it("has the specified font family on regular attributes") {
                            expect((regularAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                        }
                        it("has the specified point size on bold attributes") {
                            expect((boldAttributes[NSFontAttributeName] as! UIFont).pointSize) == 15
                        }
                        it("has the specified font family on bold attributes") {
                            expect((boldAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                        }
                        it("the final string is the same") {
                            expect(result.string) == sut
                        }
                    }
                    context("ignoreText NOT contained in string") {
                        beforeEach {
                            sut = "house for rent"
                            ignoreText = "caca"
                            font = UIFont.systemFont(ofSize: 15)
                            
                            result = sut.makeBold(ignoringText: ignoreText, font: font)
                            
                            regularAttributes = result.attributes(at: 0,
                                                                  longestEffectiveRange: nil,
                                                                  in: NSRange(location: 0, length: ignoreText.count))
                            
                            let boldStarIndex = ignoreText.count > 0 ? ignoreText.count + 1 : 0
                            let boldLength = result.string.count-ignoreText.count
                            boldAttributes = result.attributes(at: boldStarIndex,
                                                               longestEffectiveRange: nil,
                                                               in: NSRange(location: boldStarIndex, length: boldLength))
                        }
                        it("has the specified point size on regular attributes") {
                            expect((regularAttributes[NSFontAttributeName] as! UIFont).pointSize) == 15
                        }
                        it("has the specified font family on regular attributes") {
                            expect((regularAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                        }
                        it("has the specified point size on bold attributes") {
                            expect((boldAttributes[NSFontAttributeName] as! UIFont).pointSize) == 15
                        }
                        it("has the specified font family on bold attributes") {
                            expect((boldAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                        }
                        it("the final string is the same") {
                            expect(result.string) == sut
                        }
                    }
                    context("ignoreText bigger than string") {
                        beforeEach {
                            sut = "house"
                            ignoreText = "house for rent"
                            font = UIFont.systemFont(ofSize: 15)
                            
                            result = sut.makeBold(ignoringText: ignoreText, font: font)
                            
                            regularAttributes = result.attributes(at: 0,
                                                                  longestEffectiveRange: nil,
                                                                  in: NSRange(location: 0, length: sut.count))
                        }
                        it("has the specified point size on regular attributes") {
                            expect((regularAttributes[NSFontAttributeName] as! UIFont).pointSize) == 15
                        }
                        it("has the specified font family on regular attributes") {
                            expect((regularAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                        }
                        it("the final string is the same") {
                            expect(result.string) == sut
                        }
                    }

                }
            }
        }
    }
}
