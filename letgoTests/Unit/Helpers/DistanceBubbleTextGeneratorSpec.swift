//
//  DistanceBubbleTextGeneratorSpec.swift
//  LetGo
//
//  Created by Dídac on 30/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import LGComponents

class DistanceBubbleTextGeneratorSpec: QuickSpec {
    override func spec() {

        var sut: DistanceBubbleTextGenerator!
        var locationManager: MockLocationManager!
        var featureFlags: MockFeatureFlags!

        describe("bubble text generation") {
            context ("bubble interactive") {
                var place: Place?
                var radius: Int?
                beforeEach {
                    locationManager = MockLocationManager()
                    featureFlags = MockFeatureFlags()
                    sut = DistanceBubbleTextGenerator(locationManager: locationManager, featureFlags: featureFlags)
                }
                context ("location filters not set") {
                    context ("Current location doesn't have a city") {
                        beforeEach {
                            let postalAddress = PostalAddress(address: "", city: nil, zipCode: "08039", state: "", countryCode: "es", country: "")
                            let location = LGLocation(latitude: 41, longitude: 2, type: .sensor, postalAddress: postalAddress)
                            locationManager.currentLocation = location
                        }

                        it ("1 Km -> Near you - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: nil)) == "\(R.Strings.productDistanceNearYou) - 1 km"
                        }
                        it ("100 Km -> Near you - more than 20 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: nil)) == "\(R.Strings.productDistanceNearYou) - \(R.Strings.productDistanceMoreThan("20 km"))"
                        }

                    }
                    context ("Current location has a city") {
                        context ("city is not empty") {
                            beforeEach {
                                let postalAddress = PostalAddress(address: "", city: "Barcelona", zipCode: "08039", state: "", countryCode: "es", country: "")
                                let location = LGLocation(latitude: 41, longitude: 2, type: .sensor, postalAddress: postalAddress)
                                locationManager.currentLocation = location
                            }

                            it ("1 Km -> Near you - 1 km") {
                                expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: nil)) == "Barcelona - 1 km"
                            }
                            it ("100 Km -> Near you - more than 20 km") {
                                expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: nil)) == "Barcelona - \(R.Strings.productDistanceMoreThan("20 km"))"
                            }
                        }
                        context ("city is empty") {
                            beforeEach {
                                let postalAddress = PostalAddress(address: "", city: "", zipCode: "08039", state: "", countryCode: "es", country: "")
                                let location = LGLocation(latitude: 41, longitude: 2, type: .sensor, postalAddress: postalAddress)
                                locationManager.currentLocation = location
                            }

                            it ("1 Km -> Near you - 1 km") {
                                expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: nil)) == "\(R.Strings.productDistanceNearYou) - 1 km"
                            }
                            it ("100 Km -> Near you - more than 20 km") {
                                expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: nil)) == "\(R.Strings.productDistanceNearYou) - \(R.Strings.productDistanceMoreThan("20 km"))"
                            }
                        }
                    }
                }
                context ("location is set, radius is not set") {
                    context ("location has city & zipcode") {
                        context ("city is not empty") {
                            beforeEach {
                                let postalAddress = PostalAddress(address: "", city: "Barcelona", zipCode: "08039", state: "", countryCode: "es", country: "")
                                let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                                place = Place(postalAddress: postalAddress, location: location)
                            }
                            it ("1 Km -> Barcelona - 1 km") {
                                expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: place)) == "Barcelona - 1 km"
                            }
                            it ("100 Km -> Barcelona - more than 20 km") {
                                expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: place)) == "Barcelona - \(R.Strings.productDistanceMoreThan("20 km"))"
                            }
                        }
                        context ("city is empty") {
                            beforeEach {
                                let postalAddress = PostalAddress(address: "", city: "", zipCode: "08039", state: "", countryCode: "es", country: "")
                                let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                                place = Place(postalAddress: postalAddress, location: location)
                            }
                            it ("1 Km -> Barcelona - 1 km") {
                                expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: place)) == "08039 - 1 km"
                            }
                            it ("100 Km -> Barcelona - more than 20 km") {
                                expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: place)) == "08039 - \(R.Strings.productDistanceMoreThan("20 km"))"
                            }
                        }
                    }
                    context ("location has no city, but has zip code") {
                        beforeEach {
                            let postalAddress = PostalAddress(address: "", city: nil, zipCode: "08039", state: "", countryCode: "es", country: "")
                            let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                            place = Place(postalAddress: postalAddress, location: location)
                        }
                        it ("1 Km -> Barcelona - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: place)) == "08039 - 1 km"
                        }
                        it ("100 Km -> Barcelona - more than 20 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: place)) == "08039 - \(R.Strings.productDistanceMoreThan("20 km"))"
                        }
                    }
                    context ("location has no city, neither has zip code") {
                        beforeEach {
                            let postalAddress = PostalAddress.emptyAddress()
                            let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                            place = Place(postalAddress: postalAddress, location: location)
                        }
                        it ("1 Km -> Barcelona - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: nil, place: place)) == "\(R.Strings.productDistanceCustomLocation) - 1 km"
                        }
                        it ("100 Km -> Barcelona - more than 20 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: nil, place: place)) == "\(R.Strings.productDistanceCustomLocation) - \(R.Strings.productDistanceMoreThan("20 km"))"
                        }
                    }
                }
                context ("radius is set, location is not") {
                    beforeEach {
                        radius = 30
                    }
                    context ("Current location doesn't have a city") {
                        beforeEach {
                            let postalAddress = PostalAddress(address: "", city: nil, zipCode: "08039", state: "", countryCode: "es", country: "")
                            let location = LGLocation(latitude: 41, longitude: 2, type: .sensor, postalAddress: postalAddress)
                            locationManager.currentLocation = location
                        }
                        it ("1 Km -> Barcelona - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: radius, place: nil)) == "\(R.Strings.productDistanceNearYou) - 1 km"
                        }
                        it ("100 Km -> Barcelona - 30 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: radius, place: nil)) == "\(R.Strings.productDistanceNearYou) - 30 km"
                        }

                    }
                    context ("Current location has a city") {
                        beforeEach {
                            let postalAddress = PostalAddress(address: "", city: "Barcelona", zipCode: "08039", state: "", countryCode: "es", country: "")
                            let location = LGLocation(latitude: 41, longitude: 2, type: .sensor, postalAddress: postalAddress)
                            locationManager.currentLocation = location
                        }
                        it ("1 Km -> Barcelona - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: radius, place: nil)) == "Barcelona - 1 km"
                        }
                        it ("100 Km -> Barcelona - 30 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: radius, place: nil)) == "Barcelona - 30 km"
                        }
                    }
                }
                context ("both location and radius are set") {
                    context ("location has city & zipcode") {
                        beforeEach {
                            let postalAddress = PostalAddress(address: "", city: "Barcelona", zipCode: "08039", state: "", countryCode: "es", country: "")
                            let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                            place = Place(postalAddress: postalAddress, location: location)
                            radius = 30
                        }
                        it ("1 Km -> Barcelona - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: radius, place: place)) == "Barcelona - 1 km"
                        }
                        it ("100 Km -> Barcelona - 30 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: radius, place: place)) == "Barcelona - 30 km"
                        }
                    }
                    context ("location has no city, but has zip code") {
                        beforeEach {
                            let postalAddress = PostalAddress(address: "", city: nil, zipCode: "08039", state: "", countryCode: "es", country: "")
                            let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                            place = Place(postalAddress: postalAddress, location: location)
                            radius = 30
                        }
                        it ("1 Km -> 08039 - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: radius, place: place)) == "08039 - 1 km"
                        }
                        it ("100 Km -> 08039 - 30 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: radius, place: place)) == "08039 - 30 km"
                        }
                    }
                    context ("location has no city, neither has zip code") {
                        beforeEach {
                            let postalAddress = PostalAddress.emptyAddress()
                            let location = LGLocationCoordinates2D(latitude: 41.38, longitude: 2.18)
                            place = Place(postalAddress: postalAddress, location: location)
                            radius = 30
                        }
                        it ("1 Km -> Custom Location - 1 km") {
                            expect(sut.bubbleInfoText(forDistance: 1, type: .km, distanceRadius: radius, place: place)) == "\(R.Strings.productDistanceCustomLocation) - 1 km"
                        }
                        it ("100 Km -> Custom Location - 30 km") {
                            expect(sut.bubbleInfoText(forDistance: 100, type: .km, distanceRadius: radius, place: place)) == "\(R.Strings.productDistanceCustomLocation) - 30 km"
                        }
                    }
                }
            }
        }
    }
}
