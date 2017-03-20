//
//  Dictionary+FilterSpec.swift
//  LetGo
//
//  Created by Dídac on 09/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class DictionaryFilterSpec: QuickSpec {
    override func spec() {
        var sut: [String:String] = [:]

        describe("Dictionary + Filter") {
            beforeEach {
                sut = ["a": "first",
                       "b": "second",
                       "c": "third",
                       "d": "forth"]
            }
            context ("dictionary contains the keys") {
                it ("contains the items matching the keys") {
                    expect(sut.filter(keys: ["a", "c"])) == ["a": "first", "c": "third"]
                }
            }
            context ("dictionary contains some keys") {
                it ("contains the items matching the keys") {
                    expect(sut.filter(keys: ["a", "z", "d"])) == ["a": "first", "d": "forth"]
                }
            }
            context ("dictionary doesn't contain the keys") {
                it ("contains the items matching the keys") {
                    expect(sut.filter(keys: ["derp", "herp"])) == [:]
                }
            }
        }
    }
}
