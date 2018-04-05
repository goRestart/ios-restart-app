//
//  ABTestsSpec.swift
//  letgoTests
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import LetGoGodMode

class ABTestsSpec: QuickSpec {

    override func spec() {
        var syncer: LeamplumSyncerCounter!
        var uniqueSyncer: LeamplumSyncerCounter!

        var sut: ABTests!

        var legacy: LegacyABGroup!
        var realEstate: RealEstateABGroup!
        var retention: RetentionABGroup!
        var money: MoneyABGroup!
        var chat: ChatABGroup!
        var core: CoreABGroup!

        afterEach { syncer.clear() }

        describe("ABTests") {
            beforeEach {
                syncer = LeamplumSyncerCounter()
                sut = ABTests(syncer: syncer)

                legacy = LegacyABGroup.make()
                realEstate = RealEstateABGroup.make()
                core = CoreABGroup.make()
                chat = ChatABGroup.make()
                money = MoneyABGroup.make()
                retention = RetentionABGroup.make()
            }

            context("registering all the variables") {
                beforeEach {
                    sut.registerVariables()
                }
                it("registers all the variables") {
                    expect(syncer.syncedCount) == 48
                }
            }

            context("registering all the variables") {
                beforeEach {
                    sut.registerVariables()
                    uniqueSyncer = LeamplumSyncerCounter()

                    uniqueSyncer.sync(variables: Array(Set(legacy.intVariables)))
                    uniqueSyncer.sync(variables: Array(Set(legacy.boolVariables)))
                    uniqueSyncer.sync(variables: Array(Set(legacy.stringVariables)))
                    uniqueSyncer.sync(variables: Array(Set(legacy.floatVariables)))

                    uniqueSyncer.sync(variables: Array(Set(realEstate.intVariables)))
                    uniqueSyncer.sync(variables: Array(Set(realEstate.boolVariables)))
                    uniqueSyncer.sync(variables: Array(Set(realEstate.stringVariables)))
                    uniqueSyncer.sync(variables: Array(Set(realEstate.floatVariables)))

                    uniqueSyncer.sync(variables: Array(Set(core.intVariables)))
                    uniqueSyncer.sync(variables: Array(Set(core.boolVariables)))
                    uniqueSyncer.sync(variables: Array(Set(core.stringVariables)))
                    uniqueSyncer.sync(variables: Array(Set(core.floatVariables)))

                    uniqueSyncer.sync(variables: Array(Set(chat.intVariables)))
                    uniqueSyncer.sync(variables: Array(Set(chat.boolVariables)))
                    uniqueSyncer.sync(variables: Array(Set(chat.stringVariables)))
                    uniqueSyncer.sync(variables: Array(Set(chat.floatVariables)))

                    uniqueSyncer.sync(variables: Array(Set(money.intVariables)))
                    uniqueSyncer.sync(variables: Array(Set(money.boolVariables)))
                    uniqueSyncer.sync(variables: Array(Set(money.stringVariables)))
                    uniqueSyncer.sync(variables: Array(Set(money.floatVariables)))

                    uniqueSyncer.sync(variables: Array(Set(retention.intVariables)))
                    uniqueSyncer.sync(variables: Array(Set(retention.boolVariables)))
                    uniqueSyncer.sync(variables: Array(Set(retention.stringVariables)))
                    uniqueSyncer.sync(variables: Array(Set(retention.floatVariables)))
                }
                it("the registered variables are unique") {
                    expect(syncer.syncedCount) == uniqueSyncer.syncedCount
                }
            }

            context("registering all the variables") {
                it("the legacy int variables registered are 13") {
                    expect(legacy.intVariables.count) == 13
                }

                it("the legacy bool variables registered are 8") {
                    expect(legacy.boolVariables.count) == 8
                }

                it("the legacy string variables registered are 1") {
                    expect(legacy.stringVariables.count) == 1
                }

                it("the legacy float variables registered are 0") {
                    expect(legacy.floatVariables.count) == 0
                }
            }
            
            context("manually registering all the legacy variables") {
                beforeEach {
                    syncer.sync(variables: legacy.intVariables)
                    syncer.sync(variables: legacy.boolVariables)
                    syncer.sync(variables: legacy.stringVariables)
                    syncer.sync(variables: legacy.floatVariables)
                }
                it("the variables registered are 22") {
                    expect(syncer.syncedCount) == 22
                }
            }
            
            context("registering all the variables") {
                it("the realestate int variable registered are 4") {
                    expect(realEstate.intVariables.count) == 4
                }
                
                it("the realestate bool variable registered are 0") {
                    expect(realEstate.boolVariables.count) == 0
                }
                
                it("the realestate string variable registered are 0") {
                    expect(realEstate.stringVariables.count) == 0
                }
                
                it("the realestate float variable registered are 0") {
                    expect(realEstate.floatVariables.count) == 0
                }
            }

            context("manually registering all the real estate variables") {
                beforeEach {
                    syncer.sync(variables: realEstate.intVariables)
                    syncer.sync(variables: realEstate.boolVariables)
                    syncer.sync(variables: realEstate.stringVariables)
                    syncer.sync(variables: realEstate.floatVariables)
                }
                it("the variables registered are 4") {
                    expect(syncer.syncedCount) == 4
                }
            }

            context("registering all the variables") {
                it("the retention int variable registered are 2") {
                    expect(retention.intVariables.count) == 2
                }

                it("the retention bool variable registered are 0") {
                    expect(retention.boolVariables.count) == 0
                }

                it("the retention string variable registered are 0") {
                    expect(retention.stringVariables.count) == 0
                }

                it("the retention float variable registered are 0") {
                    expect(retention.floatVariables.count) == 0
                }
            }

            context("manually registering all the retention variables") {
                beforeEach {
                    syncer.sync(variables: retention.intVariables)
                    syncer.sync(variables: retention.boolVariables)
                    syncer.sync(variables: retention.stringVariables)
                    syncer.sync(variables: retention.floatVariables)
                }
                it("the variables registered are 2") {
                    expect(syncer.syncedCount) == 2
                }
            }

            context("registering all the variables") {
                it("the money int variable registered are 6") {
                    expect(money.intVariables.count) == 6
                }

                it("the money bool variable registered are 1") {
                    expect(money.boolVariables.count) == 1
                }

                it("the money string variable registered are 0") {
                    expect(money.stringVariables.count) == 0
                }

                it("the money float variable registered are 0") {
                    expect(money.floatVariables.count) == 0
                }
            }

            context("manually registering all the money variables") {
                beforeEach {
                    syncer.sync(variables: money.intVariables)
                    syncer.sync(variables: money.boolVariables)
                    syncer.sync(variables: money.stringVariables)
                    syncer.sync(variables: money.floatVariables)
                }
                it("the variables registered are 7") {
                    expect(syncer.syncedCount) == 7
                }
            }

            context("registering all the variables") {
                it("the chat int variable registered are 3") {
                    expect(chat.intVariables.count) == 3
                }

                it("the chat bool variable registered are 3") {
                    expect(chat.boolVariables.count) == 3
                }

                it("the chat string variable registered are 0") {
                    expect(chat.stringVariables.count) == 0
                }

                it("the chat float variable registered are 0") {
                    expect(chat.floatVariables.count) == 0
                }
            }

            context("manually registering all the chat variables") {
                beforeEach {
                    syncer.sync(variables: chat.intVariables)
                    syncer.sync(variables: chat.boolVariables)
                    syncer.sync(variables: chat.stringVariables)
                    syncer.sync(variables: chat.floatVariables)
                }
                it("the variables registered are 6") {
                    expect(syncer.syncedCount) == 6
                }
            }

            context("registering all the variables") {
                it("the chat int variable registered are 7") {
                    expect(core.intVariables.count) == 7
                }

                it("the chat bool variable registered are 0") {
                    expect(core.boolVariables.count) == 0
                }

                it("the chat string variable registered are 0") {
                    expect(core.stringVariables.count) == 0
                }

                it("the chat float variable registered are 0") {
                    expect(core.floatVariables.count) == 0
                }
            }

            context("manually registering all the core variables") {
                beforeEach {
                    syncer.sync(variables: core.intVariables)
                    syncer.sync(variables: core.boolVariables)
                    syncer.sync(variables: core.stringVariables)
                    syncer.sync(variables: core.floatVariables)
                }
                it("the variables registered are 6") {
                    expect(syncer.syncedCount) == 7
                }
            }
        }
    }

    private class LeamplumSyncerCounter: LeamplumSyncerType {
        var syncedCount: Int = 0
        var trackingCount: Int = 0

        func clear() {
            syncedCount = 0
            trackingCount = 0
        }

        func sync(variables: [ABRegistrable]) {
            syncedCount += variables.count
        }
        func trackingData(variables: [ABTrackable]) -> [(String, ABGroup)] {
            trackingCount += variables.count
            return variables.map { _ in return ("I don't care", ABGroup.core) }
        }
    }
}

