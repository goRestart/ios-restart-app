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
        
        var quickAnswers: [[QuickAnswer]] = [[]]
        var isFree: Bool!
        var isDynamic: Bool!
        var isNegotiable: Bool!
        
        describe("quickAnswersForPeriscope func") {
            context("is not free, is not dynamic, is not negotiable") {
                beforeEach {
                    isFree = false
                    isDynamic = false
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.isNegotiable]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition]
                }
            }
            context("is not free, is not dynamic, is negotiable") {
                beforeEach {
                    isFree = false
                    isDynamic = false
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.isNegotiable]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition]
                }
            }
            context("is not free, is dynamic, is not negotiable") {
                beforeEach {
                    isFree = false
                    isDynamic = true
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .stillForSale, .freeStillHave]
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
                it("matches fourth group with the right negotiable quick answers") {
                    expect(quickAnswers[3]) == [.isNegotiable, .priceFirm, .priceWillingToNegotiate]
                }
            }
            context("is not free, is dynamic, is negotiable") {
                beforeEach {
                    isFree = false
                    isDynamic = true
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .stillForSale, .freeStillHave]
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
                it("matches fourth group with the right price quick answers") {
                    expect(quickAnswers[3]) == [.priceAsking]
                }
            }
            context("is free, is not dynamic, is not negotiable") {
                beforeEach {
                    isFree = true
                    isDynamic = false
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.interested]
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == [.meetUp]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition]
                }
            }
            context("is free, is not dynamic, is negotiable") {
                beforeEach {
                    isFree = true
                    isDynamic = false
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.interested]
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == [.meetUp]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition]
                }
            }
            context("is free, is dynamic, is not negotiable") {
                beforeEach {
                    isFree = true
                    isDynamic = true
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .freeStillHave]
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
            }
            context("is free, is dynamic, is negotiable") {
                beforeEach {
                    isFree = true
                    isDynamic = true
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForPeriscope(isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 3 groups of quick answers") {
                    expect(quickAnswers.count) == 3
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .freeStillHave]
                }
                it("matches second group with the right meetUp quick answers") {
                    expect(quickAnswers[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
            }
        }
        
        describe("quickAnswersForChat func") {
            
            var isBuyer: Bool!
            
            context("is not free, is not buyer, is not dynamic, is not negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = false
                    isDynamic = false
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.productStillForSale]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.whatsOffer]
                }
                it("matches third group with the right negotiable quick answers") {
                    expect(quickAnswers[2]) == [.negotiableYes]
                }
                it("matches fourth group with the right no negotiable quick answers") {
                    expect(quickAnswers[3]) == [.negotiableNo]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
                it("matches sixth group with the right product sold quick answers") {
                    expect(quickAnswers[5]) == [.productSold]
                }
            }
            context("is not free, is not buyer, is not dynamic, is negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = false
                    isDynamic = false
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.productStillForSale]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.whatsOffer]
                }
                it("matches third group with the right negotiable quick answers") {
                    expect(quickAnswers[2]) == [.negotiableYes]
                }
                it("matches fourth group with the right no negotiable quick answers") {
                    expect(quickAnswers[3]) == [.negotiableNo]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
                it("matches sixth group with the right product sold quick answers") {
                    expect(quickAnswers[5]) == [.productSold]
                }
            }
            context("is not free, is not buyer, is dynamic, is not negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = false
                    isDynamic = true
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.freeAvailable]
                }
                it("matches second group with the right product sold quick answers") {
                    expect(quickAnswers[1]) == [.productSold]
                }
                it("matches third group with the right not negotiable quick answers") {
                    expect(quickAnswers[2]) == [.negotiableNo]
                }
                it("matches fourth group with the right interested quick answers") {
                    expect(quickAnswers[3]) == [.interested]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
                it("matches sixth group with the right meet up quick answers") {
                    expect(quickAnswers[5]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
            }
            context("is not free, is not buyer, is dynamic, is negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = false
                    isDynamic = true
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.freeAvailable]
                }
                it("matches second group with the right product sold quick answers") {
                    expect(quickAnswers[1]) == [.productSold]
                }
                it("matches third group with the right not negotiable quick answers") {
                    expect(quickAnswers[2]) == [.negotiableYes, .whatsOffer]
                }
                it("matches fourth group with the right interested quick answers") {
                    expect(quickAnswers[3]) == [.interested]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
                it("matches sixth group with the right meet up quick answers") {
                    expect(quickAnswers[5]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
            }
            context("is not free, is buyer, is not dynamic, is not negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = true
                    isDynamic = false
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.interested]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.isNegotiable]
                }
                it("matches third group with the right would like to buy quick answers") {
                    expect(quickAnswers[2]) == [.likeToBuy]
                }
                it("matches fourth group with the right meet up quick answers") {
                    expect(quickAnswers[3]) == [.meetUp]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
            }
            context("is not free, is buyer, is not dynamic, is negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = true
                    isDynamic = false
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.interested]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.isNegotiable]
                }
                it("matches third group with the right would like to buy quick answers") {
                    expect(quickAnswers[2]) == [.likeToBuy]
                }
                it("matches fourth group with the right meet up quick answers") {
                    expect(quickAnswers[3]) == [.meetUp]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
            }
            context("is not free, is buyer, is dynamic, is not negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = true
                    isDynamic = true
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .stillForSale, .freeStillHave]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.isNegotiable, .priceFirm, .priceWillingToNegotiate]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
                it("matches fourth group with the right meet up quick answers") {
                    expect(quickAnswers[3]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches fifth group with the right interested quick answers") {
                    expect(quickAnswers[4]) == [.interested]
                }
                it("matches sixth group with the right not interested quick answers") {
                    expect(quickAnswers[5]) == [.notInterested]
                }
            }
            context("is not free, is buyer, is dynamic, is negotiable") {
                beforeEach {
                    isFree = false
                    isBuyer = true
                    isDynamic = true
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 6 groups of quick answers") {
                    expect(quickAnswers.count) == 6
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .stillForSale, .freeStillHave]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.priceAsking]
                }
                it("matches third group with the right condition quick answers") {
                    expect(quickAnswers[2]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
                it("matches fourth group with the right meet up quick answers") {
                    expect(quickAnswers[3]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches fifth group with the right interested quick answers") {
                    expect(quickAnswers[4]) == [.interested]
                }
                it("matches sixth group with the right not interested quick answers") {
                    expect(quickAnswers[5]) == [.notInterested]
                }
            }
            context("is free, is not buyer, is not dynamic, is not negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = false
                    isDynamic = false
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.freeYours]
                }
                it("matches second group with the right availability quick answers") {
                    expect(quickAnswers[1]) == [.freeAvailable]
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == [.meetUp]
                }
                it("matches fourth group with the right not available quick answers") {
                    expect(quickAnswers[3]) == [.freeNotAvailable]
                }
            }
            context("is free, is not buyer, is not dynamic, is negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = false
                    isDynamic = false
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.freeYours]
                }
                it("matches second group with the right availability quick answers") {
                    expect(quickAnswers[1]) == [.freeAvailable]
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == [.meetUp]
                }
                it("matches fourth group with the right not available quick answers") {
                    expect(quickAnswers[3]) == [.freeNotAvailable]
                }
            }
            context("is free, is not buyer, is dynamic, is not negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = false
                    isDynamic = true
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.freeAvailable]
                }
                it("matches second group with the right not available quick answers") {
                    expect(quickAnswers[1]) == [.freeNotAvailable]
                }
                it("matches third group with the right interested quick answers") {
                    expect(quickAnswers[2]) == [.interested]
                }
                it("matches fourth group with the right not interested quick answers") {
                    expect(quickAnswers[3]) == [.notInterested]
                }
                it("matches fifth group with the right meet up quick answers") {
                    expect(quickAnswers[4]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
            }
            context("is free, is not buyer, is dynamic, is negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = false
                    isDynamic = true
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.freeAvailable]
                }
                it("matches second group with the right not available quick answers") {
                    expect(quickAnswers[1]) == [.freeNotAvailable]
                }
                it("matches third group with the right interested quick answers") {
                    expect(quickAnswers[2]) == [.interested]
                }
                it("matches fourth group with the right not interested quick answers") {
                    expect(quickAnswers[3]) == [.notInterested]
                }
                it("matches fifth group with the right meet up quick answers") {
                    expect(quickAnswers[4]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
            }
            context("is free, is buyer, is not dynamic, is not negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = true
                    isDynamic = false
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.interested]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.freeStillHave]
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == [.meetUp]
                }
                it("matches fourth group with the right not interested quick answers") {
                    expect(quickAnswers[3]) == [.notInterested]
                }
            }
            context("is free, is buyer, is not dynamic, is negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = true
                    isDynamic = false
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 4 groups of quick answers") {
                    expect(quickAnswers.count) == 4
                }
                it("matches first group with the right interested quick answers") {
                    expect(quickAnswers[0]) == [.interested]
                }
                it("matches second group with the right negotiable quick answers") {
                    expect(quickAnswers[1]) == [.freeStillHave]
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == [.meetUp]
                }
                it("matches fourth group with the right not interested quick answers") {
                    expect(quickAnswers[3]) == [.notInterested]
                }
            }
            context("is free, is buyer, is dynamic, is not negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = true
                    isDynamic = true
                    isNegotiable = false
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .freeStillHave]
                }
                it("matches second group with the right condition quick answers") {
                    expect(quickAnswers[1]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches fourth group with the right interested quick answers") {
                    expect(quickAnswers[3]) == [.interested]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
            }
            context("is free, is buyer, is dynamic, is negotiable") {
                beforeEach {
                    isFree = true
                    isBuyer = true
                    isDynamic = true
                    isNegotiable = true
                    quickAnswers = QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree, isDynamic: isDynamic, isNegotiable: isNegotiable)
                }
                it("receives 5 groups of quick answers") {
                    expect(quickAnswers.count) == 5
                }
                it("matches first group with the right availability quick answers") {
                    expect(quickAnswers[0]) == [.stillAvailable, .freeStillHave]
                }
                it("matches second group with the right condition quick answers") {
                    expect(quickAnswers[1]) == [.productCondition, .productConditionGood, .productConditionDescribe]
                }
                it("matches third group with the right meet up quick answers") {
                    expect(quickAnswers[2]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                }
                it("matches fourth group with the right interested quick answers") {
                    expect(quickAnswers[3]) == [.interested]
                }
                it("matches fifth group with the right not interested quick answers") {
                    expect(quickAnswers[4]) == [.notInterested]
                }
            }
        }
    }
}
