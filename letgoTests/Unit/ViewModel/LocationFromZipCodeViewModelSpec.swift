//
//  LocationFromZipCodeViewModelSpec.swift
//  LetGo
//
//  Created by Dídac on 31/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

class LocationFromZipCodeViewModelSpec: BaseViewModelSpec {

    override func spec() {
        fdescribe("LocationFromZipCodeViewModelSpec") {

            var locationManager: LocationManager!
            var searchService: MockSearchLocationSuggestionsService!
            var postalAddressService: MockPostalAddressRetrievalService!

            var sut: LocationFromZipCodeViewModel!

            context ("no initial place") {
                beforeEach {
                    locationManager = MockLocationManager()

                    let postalAddress = PostalAddress(address: "", city: "New York", zipCode: "12345", state: "", countryCode: "us", country: "")
                    let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                    let place = Place(postalAddress: postalAddress, location: location)

                    searchService = MockSearchLocationSuggestionsService(value: [place])

                    postalAddressService = MockPostalAddressRetrievalService(value: place)

                    sut = LocationFromZipCodeViewModel(initialPlace: nil,
                                                       locationManager: locationManager,
                                                       searchService: searchService,
                                                       postalAddressService: postalAddressService)
                }
                context ("zip code has a correct format") {
                    beforeEach {
                        sut.zipCode.value = "12345"
                    }
                    context ("get address from zip code") {
                        beforeEach {
                            sut.updateAddressFromZipCode()

                        }
                        it ("full address has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("12345, New York"))
                        }
                    }
                    context ("get Address From Current Location") {
                        beforeEach {
                            sut.updateAddressFromCurrentLocation()
                        }
                        it ("full address has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("12345, New York"))
                        }
                    }
                }
                context ("zip code has NOT a correct format") {
                    beforeEach {
                        sut.zipCode.value = "abcd"
                    }
                    context ("get address from zip code") {
                        beforeEach {
                            sut.updateAddressFromZipCode()

                        }
                        it ("there's no full address") {
                            expect(sut.fullAddress.value).toEventually(beNil())
                        }
                    }
                    context ("get Address From Current Location") {
                        beforeEach {
                            sut.updateAddressFromCurrentLocation()
                        }
                        it ("full address has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("12345, New York"))
                        }
                    }
                }
            }
            context ("we have an initial place") {
                beforeEach {
                    locationManager = MockLocationManager()

                    let initialPostalAddress = PostalAddress(address: "", city: "Palo Bajo", zipCode: "06660", state: "", countryCode: "us", country: "")
                    let initialLocation = LGLocationCoordinates2D(latitude: 43.38, longitude: 12.18)
                    let initialPlace = Place(postalAddress: initialPostalAddress, location: initialLocation)

                    let postalAddress = PostalAddress(address: "", city: "New York", zipCode: "12345", state: "", countryCode: "us", country: "")
                    let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                    let resultPlace = Place(postalAddress: postalAddress, location: location)

                    searchService = MockSearchLocationSuggestionsService(value: [resultPlace])

                    postalAddressService = MockPostalAddressRetrievalService(value: resultPlace)

                    sut = LocationFromZipCodeViewModel(initialPlace: initialPlace,
                                                       locationManager: locationManager,
                                                       searchService: searchService,
                                                       postalAddressService: postalAddressService)
                }
                context ("zip code has a correct format") {
                    beforeEach {
                        sut.zipCode.value = "12345"
                    }
                    context ("get address from zip code") {
                        beforeEach {
                            sut.updateAddressFromZipCode()

                        }
                        it ("full address has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("12345, New York"))
                        }
                    }
                    context ("get Address From Current Location") {
                        beforeEach {
                            sut.updateAddressFromCurrentLocation()
                        }
                        it ("full address has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("12345, New York"))
                        }
                    }
                }
                context ("zip code has NOT a correct format") {
                    beforeEach {
                        sut.zipCode.value = "abcd"
                    }
                    context ("get address from zip code") {
                        beforeEach {
                            sut.updateAddressFromZipCode()

                        }
                        it ("full address is the initial one, has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("06660, Palo Bajo"))
                        }
                    }
                    context ("get Address From Current Location") {
                        beforeEach {
                            sut.updateAddressFromCurrentLocation()
                        }
                        it ("full address is the initial one, has the zip and city separated by comma") {
                            expect(sut.fullAddress.value).toEventually(equal("12345, New York"))
                        }
                    }
                }
            }
        }
    }
}
