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
        var sut: NSAttributedString!
        var ignoreText: String!
        let font = UIFont.systemFont(ofSize: 15)
        var regularAttributes: [String : Any]!
        var boldAttributes: [String : Any]!
        
        fdescribe("NSAttributedString + LG methods") {
            context("setBold") {
                beforeEach {
                    sut = NSAttributedString(string: "house for rent")
                    ignoreText = "hous"
                    sut = sut.setBold(ignoreText: ignoreText, font: font)
                    regularAttributes = sut.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: 3))
                    boldAttributes = sut.attributes(at: 4, longestEffectiveRange: nil, in: NSRange(location: 4, length: 10))
                }
                it("has substrings with different attributes") {
                    //expect(regularAttributes).toNot(equal(boldAttributes))
                }
            }
        }
    }
}
