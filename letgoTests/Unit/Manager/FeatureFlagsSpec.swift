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

            context("phone locale is in Turkey") {
                beforeEach {
                    locale = Locale(identifier: "tr_TR")
                    sut = FeatureFlags(locale: locale,
                                       locationManager: locationManager,
                                       countryInfo: countryInfo,
                                       abTests: abTests,
                                       dao: dao)
                }
                
                it("has signup newsletter accept enabled") {
                    expect(sut.signUpEmailNewsletterAcceptRequired) == true
                }
                it("has signup terms and conditions accept enabled") {
                    expect(sut.signUpEmailTermsAndConditionsAcceptRequired) == true
                }
            }
            
            context("current postal address's country code is Turkey") {
                beforeEach {
                    let location = LGLocation.makeMock().updating(postalAddress: PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "tr", country: ""))
                    locationManager.currentLocation = location
                    sut = FeatureFlags(locale: locale,
                                       locationManager: locationManager,
                                       countryInfo: countryInfo,
                                       abTests: abTests,
                                       dao: dao)
                }
                
                it("has signup newsletter accept enabled") {
                    expect(sut.signUpEmailNewsletterAcceptRequired) == true
                }
                it("has signup terms and conditions accept enabled") {
                    expect(sut.signUpEmailTermsAndConditionsAcceptRequired) == true
                }
            }
            
            context("phone locale is in US") {
                beforeEach {
                    locale = Locale(identifier: "en_US")
                    sut = FeatureFlags(locale: locale,
                                       locationManager: locationManager,
                                       countryInfo: countryInfo,
                                       abTests: abTests,
                                       dao: dao)
                }
                
                it("has signup newsletter accept disabled") {
                    expect(sut.signUpEmailNewsletterAcceptRequired) == false
                }
                it("has signup terms and conditions accept disabled") {
                    expect(sut.signUpEmailTermsAndConditionsAcceptRequired) == false
                }
            }
            
            context("current postal address's country code is US") {
                beforeEach {
                    let location = LGLocation.makeMock().updating(postalAddress: PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "us", country: ""))
                    locationManager.currentLocation = location
                    sut = FeatureFlags(locale: locale,
                                       locationManager: locationManager,
                                       countryInfo: countryInfo,
                                       abTests: abTests,
                                       dao: dao)
                }
                
                it("has signup newsletter accept disabled") {
                    expect(sut.signUpEmailNewsletterAcceptRequired) == false
                }
                it("has signup terms and conditions accept disabled") {
                    expect(sut.signUpEmailTermsAndConditionsAcceptRequired) == false
                }
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
                    }
                }
            }
        }
    }
}

