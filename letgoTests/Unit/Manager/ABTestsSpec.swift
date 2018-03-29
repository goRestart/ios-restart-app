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
        var sut: ABTests!

        var legacy: LegacyGroup!
        var realEstate: RealEstateGroup!
        var retention: RetentionGroup!
        var money: MoneyGroup!
        var chat: ChatGroup!
        var core: CoreGroup!

        var syncer: LeamplumSyncerCounter!
        var uniqueSyncer: LeamplumSyncerCounter!
        core = CoreGroup.make()

        afterEach { syncer.clear() }

        fdescribe("A new set of ABTests") {
            beforeEach {
                syncer = LeamplumSyncerCounter()
                sut = ABTests(syncer: syncer)

                legacy = LegacyGroup.make()
                realEstate = RealEstateGroup.make()
                core = CoreGroup.make()
                chat = ChatGroup.make()
                money = MoneyGroup.make()
                retention = RetentionGroup.make()
            }

            context("registering all the variables") {
                beforeEach {
                    sut.registerVariables()
                }
                it("the number of registered variables matches") {
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
                it("the number of uniques registered variables matches the manual way") {
                    expect(syncer.syncedCount) == uniqueSyncer.syncedCount
                }
            }

            context("Checking legacy variables") {
                it("it has 7 int variables") {
                    expect(legacy.intVariables.count) == 13
                }

                it("it has 0 bool variables") {
                    expect(legacy.boolVariables.count) == 8
                }

                it("it has 0 string variables") {
                    expect(legacy.stringVariables.count) == 1
                }

                it("it has 0 float variables") {
                    expect(legacy.floatVariables.count) == 0
                }
            }
            
            context("registering only the legacy variables") {
                beforeEach {
                    syncer.sync(variables: legacy.intVariables)
                    syncer.sync(variables: legacy.boolVariables)
                    syncer.sync(variables: legacy.stringVariables)
                    syncer.sync(variables: legacy.floatVariables)
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 22
                }
            }
            
            context("Checking real estate variables") {
                it("it has 7 int variables") {
                    expect(realEstate.intVariables.count) == 4
                }
                
                it("it has 0 bool variables") {
                    expect(realEstate.boolVariables.count) == 0
                }
                
                it("it has 0 string variables") {
                    expect(realEstate.stringVariables.count) == 0
                }
                
                it("it has 0 float variables") {
                    expect(realEstate.floatVariables.count) == 0
                }
            }

            context("registering only the real estate variables") {
                beforeEach {
                    syncer.sync(variables: realEstate.intVariables)
                    syncer.sync(variables: realEstate.boolVariables)
                    syncer.sync(variables: realEstate.stringVariables)
                    syncer.sync(variables: realEstate.floatVariables)
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 4
                }
            }

            context("Checking retention variables") {
                it("it has 7 int variables") {
                    expect(retention.intVariables.count) == 2
                }

                it("it has 0 bool variables") {
                    expect(retention.boolVariables.count) == 0
                }

                it("it has 0 string variables") {
                    expect(retention.stringVariables.count) == 0
                }

                it("it has 0 float variables") {
                    expect(retention.floatVariables.count) == 0
                }
            }

            context("registering only the retention variables") {
                beforeEach {
                    syncer.sync(variables: retention.intVariables)
                    syncer.sync(variables: retention.boolVariables)
                    syncer.sync(variables: retention.stringVariables)
                    syncer.sync(variables: retention.floatVariables)
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 2
                }
            }

            context("Checking money variables") {
                it("it has 7 int variables") {
                    expect(money.intVariables.count) == 6
                }

                it("it has 0 bool variables") {
                    expect(money.boolVariables.count) == 1
                }

                it("it has 0 string variables") {
                    expect(money.stringVariables.count) == 0
                }

                it("it has 0 float variables") {
                    expect(money.floatVariables.count) == 0
                }
            }

            context("registering only the money variables") {
                beforeEach {
                    syncer.sync(variables: money.intVariables)
                    syncer.sync(variables: money.boolVariables)
                    syncer.sync(variables: money.stringVariables)
                    syncer.sync(variables: money.floatVariables)
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 7
                }
            }

            context("Checking chat variables") {
                it("it has 7 int variables") {
                    expect(chat.intVariables.count) == 3
                }

                it("it has 0 bool variables") {
                    expect(chat.boolVariables.count) == 3
                }

                it("it has 0 string variables") {
                    expect(chat.stringVariables.count) == 0
                }

                it("it has 0 float variables") {
                    expect(chat.floatVariables.count) == 0
                }
            }

            context("registering only the chat variables") {
                beforeEach {
                    syncer.sync(variables: chat.intVariables)
                    syncer.sync(variables: chat.boolVariables)
                    syncer.sync(variables: chat.stringVariables)
                    syncer.sync(variables: chat.floatVariables)
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 6
                }
            }

            context("Checking core variables") {
                it("it has 7 int variables") {
                    expect(core.intVariables.count) == 7
                }

                it("it has 0 bool variables") {
                    expect(core.boolVariables.count) == 0
                }

                it("it has 0 string variables") {
                    expect(core.stringVariables.count) == 0
                }

                it("it has 0 float variables") {
                    expect(core.floatVariables.count) == 0
                }
            }

            context("registering only the core variables") {
                beforeEach {
                    syncer.sync(variables: core.intVariables)
                    syncer.sync(variables: core.boolVariables)
                    syncer.sync(variables: core.stringVariables)
                    syncer.sync(variables: core.floatVariables)
                }
                it("the number of registered variables matches") {
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

