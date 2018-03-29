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
        var syncer: LeamplumSyncerCounter!

        afterEach { syncer.clear() }

        fdescribe("A new set of ABTests") {
            beforeEach {
                syncer = LeamplumSyncerCounter()
                sut = ABTests(syncer: syncer)
            }

            context("registering all the variables") {
                beforeEach {
                    sut.registerVariables()
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 49
                }
            }
            
            context("registering only the legacy variables") {
                beforeEach {
                    legacy = LegacyGroup.make()

                    syncer.sync(variables: legacy.intVariables)
                    syncer.sync(variables: legacy.boolVariables)
                    syncer.sync(variables: legacy.stringVariables)
                    syncer.sync(variables: legacy.floatVariables)
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 22
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

