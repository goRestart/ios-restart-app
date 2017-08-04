//
//  NSAttributedString+LGSpec.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class NSAttributedStringLGSpec: QuickSpec {
    override func spec() {
        
        describe("NSAttributedString + LG methods") {
            context("setBold:ignoreText:font") {
                var sut: NSAttributedString!
                var string: String!
                var ignoreText: String!
                var regularAttributes: [String : Any]!
                var boldAttributes: [String : Any]!
                var font: UIFont!
                var expectedRegularAttribute: [String : Any]!
                var expectedBoldAttribute: [String : Any]!
                
                context("with a valid font") {
                    context("ignoreText contained in string") {
                        beforeEach {
                            string = "house for rent"
                            ignoreText = "hous"
                            font = UIFont.systemFont(ofSize: 15)
                            
                            sut = NSAttributedString(string: string)
                            sut = sut.setBold(ignoreText: ignoreText, font: font)
                            
                            regularAttributes = sut.attributes(at: 0,
                                                               longestEffectiveRange: nil,
                                                               in: NSRange(location: 0, length: ignoreText.characters.count))
                            
                            let boldStarIndex = ignoreText.characters.count > 0 ? ignoreText.characters.count + 1 : 0
                            let boldLength = sut.string.characters.count-ignoreText.characters.count
                            boldAttributes = sut.attributes(at: boldStarIndex,
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
                            expect(sut.string) == string
                        }
                    }
                    context("ignoreText NOT contained in string") {
                        beforeEach {
                            string = "house for rent"
                            ignoreText = "caca"
                            font = UIFont.systemFont(ofSize: 15)
                            
                            sut = NSAttributedString(string: string)
                            sut = sut.setBold(ignoreText: ignoreText, font: font)
                            
                            regularAttributes = sut.attributes(at: 0,
                                                               longestEffectiveRange: nil,
                                                               in: NSRange(location: 0, length: ignoreText.characters.count))
                            
                            let boldStarIndex = ignoreText.characters.count > 0 ? ignoreText.characters.count + 1 : 0
                            let boldLength = sut.string.characters.count-ignoreText.characters.count
                            boldAttributes = sut.attributes(at: boldStarIndex,
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
                            expect(sut.string) == string
                        }
                    }
                    context("ignoreText nil") {
                        beforeEach {
                            string = "house for rent"
                            font = UIFont.systemFont(ofSize: 15)
                            
                            sut = NSAttributedString(string: string)
                            sut = sut.setBold(ignoreText: nil, font: font)
                            
                            regularAttributes = sut.attributes(at: 0,
                                                               longestEffectiveRange: nil,
                                                               in: NSRange(location: 0, length: ignoreText.characters.count))
                            
                            let boldStarIndex = ignoreText.characters.count > 0 ? ignoreText.characters.count + 1 : 0
                            let boldLength = sut.string.characters.count-ignoreText.characters.count
                            boldAttributes = sut.attributes(at: boldStarIndex,
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
                            expect(sut.string) == string
                        }
                    }
                }
                
                context("with a nil font") {
                    beforeEach {
                        string = "house for rent"
                        ignoreText = "hous"
                        
                        sut = NSAttributedString(string: string)
                        sut = sut.setBold(ignoreText: ignoreText, font: nil)
                        
                        regularAttributes = sut.attributes(at: 0,
                                                           longestEffectiveRange: nil,
                                                           in: NSRange(location: 0, length: ignoreText.characters.count))
                        
                        let boldStarIndex = ignoreText.characters.count > 0 ? ignoreText.characters.count + 1 : 0
                        let boldLength = sut.string.characters.count-ignoreText.characters.count
                        boldAttributes = sut.attributes(at: boldStarIndex,
                                                        longestEffectiveRange: nil,
                                                        in: NSRange(location: boldStarIndex, length: boldLength))
                    }
                    it("has the specified point size on regular attributes") {
                        expect((regularAttributes[NSFontAttributeName] as! UIFont).pointSize) == 17
                    }
                    it("has the specified font family on regular attributes") {
                        expect((regularAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                    }
                    it("has the specified point size on bold attributes") {
                        expect((boldAttributes[NSFontAttributeName] as! UIFont).pointSize) == 17
                    }
                    it("has the specified font family on bold attributes") {
                        expect((boldAttributes[NSFontAttributeName] as! UIFont).familyName) == font.familyName
                    }
                    it("the final string is the same") {
                        expect(sut.string) == string
                    }
                }

            }
        }
    }
}
