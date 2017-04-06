//
//  CountryCodeSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 03/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import Quick
import Nimble
@testable import LetGoGodMode


class CountryCodeSpec: QuickSpec {

    override func spec() {
        var sut : CountryCode!

        describe("CountryCodeSpec") {
            context("init uppercase") {
                describe("turkey") {
                    beforeEach {
                        sut = CountryCode(string:"TR")
                    }
                    it("sut is turkey") {
                        expect(sut) == .turkey
                    }
                }
                describe("usa") {
                    beforeEach {
                        sut = CountryCode(string:"US")
                    }
                    it("sut is usa") {
                        expect(sut) == .usa
                    }
                }
            }
            context("init lowercase") {
                describe("turkey") {
                    beforeEach {
                        sut = CountryCode(string:"tr")
                    }
                    it("sut is turkey") {
                        expect(sut) == .turkey
                    }
                }
                describe("usa") {
                    beforeEach {
                        sut = CountryCode(string:"us")
                    }
                    it("sut is usa") {
                        expect(sut) == .usa
                    }
                }
            }
        }
    }
}
