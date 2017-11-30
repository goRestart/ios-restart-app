//
//  FeatureFlagsSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import bumper
@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class FeatureFlagsSpec: QuickSpec {
    override func spec() {

        describe("FeatureFlags") {
            var sut: FeatureFlags!

            var locale: Locale!
            var locationManager: MockLocationManager!
            var countryInfo: MockCountryConfigurable!
            var abTests: ABTests!
            var dao: MockFeatureFlagsDAO!

            beforeEach {
                locale = Locale.makeRandom()
                locationManager = MockLocationManager()
                countryInfo = MockCountryConfigurable()
                abTests = ABTests()
                dao = MockFeatureFlagsDAO()

                sut = FeatureFlags(locale: locale,
                                   locationManager: locationManager,
                                   countryInfo: countryInfo,
                                   abTests: abTests,
                                   dao: dao)
            }

            describe("NetworkDAO interaction") {
                context("bumper disabled") {
                    context("network dao does not have any presetted value") {
                        beforeEach {
                            dao = MockFeatureFlagsDAO()
                            locale = Locale.makeRandom()
                            locationManager = MockLocationManager()
                            countryInfo = MockCountryConfigurable()
                            abTests = ABTests()

                            sut = FeatureFlags(locale: locale,
                                               locationManager: locationManager,
                                               countryInfo: countryInfo,
                                               abTests: abTests,
                                               dao: dao)
                        }

                        it("returns timeout ab test value") {
                            expect(sut.requestTimeOut.timeout) == RequestsTimeOut.fromPosition(abTests.requestsTimeOut.value).timeout
                        }
                    }
                }
            }
        }
    }
}

