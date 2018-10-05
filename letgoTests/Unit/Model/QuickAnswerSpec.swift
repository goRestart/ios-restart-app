//
//  QuickAnswerSpec.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 28/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
@testable import LetGoGodMode

class QuickAnswerSpec: QuickSpec {
    
    override func spec() {
        
        var quickAnswers: [QuickAnswer] = []
        var isFree: Bool!
        
        describe("quickAnswersForPeriscope func") {
            context("is not free") {
                beforeEach {
                    isFree = false
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches stillAvailable quick answer") {
                    expect(quickAnswers[0]) == QuickAnswer.stillAvailable
                }
                it("matches isNegotiable quick answer") {
                    expect(quickAnswers[1]) == QuickAnswer.isNegotiable
                } 
                it("matches listingCondiction quick answer") {
                    expect(quickAnswers[2]) == QuickAnswer.listingCondition
                }
            }
            context("is free") {
                beforeEach {
                    isFree = true
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == QuickAnswer.interested
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == QuickAnswer.meetUp
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == QuickAnswer.listingCondition
                }
            }
        }
        
        describe("quickAnswersForChat func") {

            var isBuyer: Bool!

            context("is not free, is not buyer") {
                beforeEach {
                    isFree = false
                    isBuyer = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree,
                                                                       chatNorrisABtestVersion: .control,
                                                                       letsMeetIsInsideBar: false)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == QuickAnswer.listingStillForSale
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == QuickAnswer.whatsOffer
                }
                it("matches third group with the right negotiable quick answers") {
                    expect(quickAnswers[2]) == QuickAnswer.negotiableYes
                }
                it("matches fourth group with the right no negotiable quick answers") {
                    expect(quickAnswers[3]) == QuickAnswer.negotiableNo
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == QuickAnswer.notInterested
                }
                it("matches sixth group with the right product sold quick answers") {
                    expect(quickAnswers[5]) == QuickAnswer.listingSold
                }
            }
            context("is not free, is buyer") {
                beforeEach {
                    isFree = false
                    isBuyer = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree,
                                                                       chatNorrisABtestVersion: .control,
                                                                       letsMeetIsInsideBar: false)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == QuickAnswer.interested
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == QuickAnswer.isNegotiable
                }
                it("matches third group with the right would like to buy quick answers") {
                    expect(quickAnswers[2]) == QuickAnswer.likeToBuy
                }
                it("matches fourth group with the right meet up quick answers") {
                    expect(quickAnswers[3]) == QuickAnswer.meetUp
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == QuickAnswer.notInterested
                }
            }
            context("is free, is not buyer") {
                beforeEach {
                    isFree = true
                    isBuyer = false

                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree,
                                                                       chatNorrisABtestVersion: .control,
                                                                       letsMeetIsInsideBar: false)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == QuickAnswer.freeYours
                }
                it("matches second group with the right availability quick answers") {
                    expect(quickAnswers[1]) == QuickAnswer.freeAvailable
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == QuickAnswer.meetUp
                }
                it("matches fourth group with the right not available quick answers") {
                    expect(quickAnswers[3]) == QuickAnswer.freeNotAvailable
                }
            }
            context("is free, is buyer") {
                beforeEach {
                    isFree = true
                    isBuyer = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree,
                                                                       chatNorrisABtestVersion: .control,
                                                                       letsMeetIsInsideBar: false)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == QuickAnswer.interested
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == QuickAnswer.freeStillHave
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == QuickAnswer.meetUp
                }
                it("matches fourth group with the right not interested quick answers") {
                    expect(quickAnswers[3]) == QuickAnswer.notInterested
                }
            }
            context("is free, is buyer, and chatNorris ABtest is active") {
                beforeEach {
                    isFree = true
                    isBuyer = true

                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree,
                                                                       chatNorrisABtestVersion: .redButton,
                                                                       letsMeetIsInsideBar: false)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[1]) == QuickAnswer.interested
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[2]) == QuickAnswer.freeStillHave
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[3]) == QuickAnswer.meetUp
                }
                pending("matches fourth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == QuickAnswer.notInterested
                }
            }
        }
    }
}

