//
//  ConfigSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import Nimble
import Argo
@testable import LetGo


class ConfigSpec: QuickSpec {
   
    override func spec() {
    
        var sut : Config!
        var json : JSON!

        describe("init") {
            beforeEach {
                
                let path = Bundle(for: self.classForCoder).path(forResource: "iOScfgMockOK", ofType: "json")
                let data = NSData(contentsOfFile: path!)!
                
                json = JSON.parse(data: data as Data)
                
                sut = Config(json: json)
            }
            context("init with data") {
                it("object not nil") {
                    expect(sut).notTo(beNil())
                }
                it("should have buildNumber set") {
                    expect(sut.buildNumber).notTo(beNil())
                }
                it("should have forceUpdateVersions set") {
                    expect(sut.forceUpdateVersions).notTo(beNil())
                }
                it("should have configURL set") {
                    expect(sut.configURL).notTo(beNil())
                }
                it("should have the num of my messages to be able to rate an user") {
                    expect(sut.myMessagesCountForRating) == 1
                }
                it("should have the num of other messages to be able to rate an user") {
                    expect(sut.otherMessagesCountForRating) == 1
                }
            }
            context("object to json") {
                
                it("should create a json representation from object") {
                    let jsonRepresentation = sut.jsonRepresentation()
                    expect(JSON(jsonRepresentation)).to(equal(json))
                }
            }
        }
    }
}
