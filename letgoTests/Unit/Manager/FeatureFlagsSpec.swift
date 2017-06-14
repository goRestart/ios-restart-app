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

            describe("initialization") {
                context("bumper disabled") {
                    context("dao did not cache websocket variable") {
                        beforeEach {
                            dao.websocketChatEnabled = nil
                            
                            sut = FeatureFlags(locale: locale,
                                               locationManager: locationManager,
                                               countryInfo: countryInfo,
                                               abTests: abTests,
                                               dao: dao)
                        }
                        
                        it("returns websocket ab test value") {
                            expect(sut.websocketChat) == abTests.websocketChat.value
                        }
                    }
                    
                    context("data cached websocket variable") {
                        beforeEach {
                            dao.websocketChatEnabled = true
                            
                            sut = FeatureFlags(locale: locale,
                                               locationManager: locationManager,
                                               countryInfo: countryInfo,
                                               abTests: abTests,
                                               dao: dao)
                        }
                        
                        it("returns websocket cached value") {
                            expect(sut.websocketChat) == dao.websocketChatEnabled
                        }
                    }
                }
            }
            
            describe("ab variables updated") {
                beforeEach {
                    sut.variablesUpdated()
                }
                
                it("saves websocket ab test value in dao") {
                    expect(dao.websocketChatEnabled) == abTests.websocketChat.value
                }
                it("saves edit location bubble ab test value in dao") {
                    expect(dao.editLocationBubble) == EditLocationBubble.fromPosition(abTests.editLocationBubble.value)
                }
                it("returns edit location bubble ab test dao value") {
                    expect(sut.editLocationBubble) == dao.editLocationBubble
                }
                it("saves cars vertical enabled ab test value in dao") {
                    expect(dao.carsVerticalEnabled) == abTests.carsVerticalEnabled.value
                }
                it("returns cars vertical enabled ab test dao value") {
                    expect(sut.carsVerticalEnabled) == dao.carsVerticalEnabled
                }
            }
        }
    }
}

