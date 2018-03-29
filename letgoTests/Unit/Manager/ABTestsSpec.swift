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
        var syncer: LeamplumSyncerCounter!

        fdescribe("A new set of ABTests") {
            beforeEach {
                syncer = LeamplumSyncerCounter()
                sut = ABTests(syncer: syncer)
            }

            context("registering the variables") {
                beforeEach {
                    sut.registerVariables()
                }
                it("the number of registered variables matches") {
                    expect(syncer.syncedCount) == 49
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
        func trackingData(variables: [ABTrackable]) -> [(String, ABGroupType)] {
            trackingCount += variables.count
            return variables.map { _ in return ("I don't care", ABGroupType.core) }
        }
    }
}

