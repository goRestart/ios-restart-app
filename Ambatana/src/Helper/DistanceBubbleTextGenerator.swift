//
//  DistanceBubbleTextGenerator.swift
//  LetGo
//
//  Created by Dídac on 30/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class DistanceBubbleTextGenerator {

    let featureFlags: FeatureFlaggeable
    let locationManager: LocationManager


    convenience init() {
        self.init(locationManager: Core.locationManager, featureFlags: FeatureFlags.sharedInstance)
    }

    init(locationManager: LocationManager, featureFlags: FeatureFlaggeable) {
        self.locationManager = locationManager
        self.featureFlags = featureFlags
    }

    /**
     Bubble Info Logic:

     If the edit Location From bubble ABCTest is inactive, we show what we've been showing until now:
     - Default ordering: "Popular near you"
     - Closest First ordering: *1 mi from you*, *More than 20 mi from you* with dynamic distance

     If It's active, we show:
     - Default Ordering: *City - XX mi* where XX is the distance radius and doesn't change
     - If the location is "custom" (edited by user in filters) we show zipCode if we don't know the city,
     or "Custom Location" if we don't know even the zipCode
     - If we're using the user location we show "Near you" if we don't know the city
     - Closest First ordering: *City - XX mi*  where XX is the distance of the products, and changes while scrolling
     */

    func bubbleInfoText(forDistance distance: Int, type: DistanceType, distanceRadius: Int?, place: Place?) -> String {

        switch featureFlags.editLocationBubble {
        case .inactive:
            let distanceString = String(format: "%d %@", arguments: [min(Constants.productListMaxDistanceLabel, distance),
                                                                     type.string])
            if distance <= Constants.productListMaxDistanceLabel {
                return LGLocalizedString.productDistanceXFromYou(distanceString)
            } else {
                return LGLocalizedString.productDistanceMoreThanFromYou(distanceString)
            }
        case .zipCode, .map:
            var maxDistance = Constants.productListMaxDistanceLabel

            if let filterDistanceRadius = distanceRadius {
                maxDistance = filterDistanceRadius
            }

            var distanceString: String? = nil
            if distance > 0 {
                distanceString = String(format: "%d %@", arguments: [min(maxDistance, distance), type.string])
                if let distanceValue = distanceString, distance > maxDistance && distanceRadius == nil {
                    distanceString = LGLocalizedString.productDistanceMoreThan(distanceValue)
                }
            }

            if let customPlace = place {
                if let city = customPlace.postalAddress?.city, !city.isEmpty {
                    return String.make(components: [city, distanceString], separator: " - ")
                } else if let zip = customPlace.postalAddress?.zipCode, !zip.isEmpty {
                    return String.make(components: [zip, distanceString], separator: " - ")
                } else {
                    return String.make(components: [LGLocalizedString.productDistanceCustomLocation, distanceString], separator: " - ")
                }
            } else {
                if let realLocationCity = locationManager.currentLocation?.postalAddress?.city, !realLocationCity.isEmpty {
                    return String.make(components: [realLocationCity, distanceString], separator: " - ")
                } else {
                    return String.make(components: [LGLocalizedString.productDistanceNearYou, distanceString], separator: " - ")
                }
            }
        }
    }
}
