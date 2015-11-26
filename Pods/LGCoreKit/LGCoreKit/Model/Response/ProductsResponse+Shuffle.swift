//
//  ProductsResponse+Shuffle.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 22/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

internal extension Product {
    
    /**
    Will calculate distance from location to product and return the kilometers group
    
    - parameter queryLocation: location to calculate distance from product
    - returns: Integer representing group of distance (kilometers to location)
    */
    func groupOfDistance(queryLocation: CLLocation) -> Int {
        
        let pLocation = self.location
        
        let productLocation = CLLocation(latitude: pLocation.latitude, longitude: pLocation.longitude)
        
        let kms = Int(floor(queryLocation.distanceFromLocation(productLocation) * 0.001))
        
        //There are N groups divided by kilometers
        return kms;
    }
    
    /**
    Will calculate freshness group using creation date into the following groups:
    - Group 1: first 72 hours [Exception: if a product of this group is sold, it goes to group 2]
    - Group 2: from 72 to 168 hours
    - Group 3: older than 168 hours
    - parameter referenceDate: Date to compute vs product.updatedAt
    - returns: group number
    */
    func groupOfFreshness(referenceDate: NSDate) -> Int {
        
        let product = self
        
        guard let createdAt = product.createdAt else {
            return 3
        }
        let productGap = referenceDate.timeIntervalSinceDate(createdAt)
        if(productGap < 259200) { //first group 72 hours
            if(product.status == .Sold){
                //There's a restriction that SOLD items cannot go to this group
                return 2
            }
            return 1
        }
        if(productGap < 604800) { // second group from 72 to 168 hours
            return 2
        }
        return 3 // Third group, all the rest
    }
    
    /**
    Returns the character to order when shuffling
    - parameter indexOfChar: Index to use
    - returns: Character from product.objectId at given index or 'z' if objectId is nil
    */
    func shuffledCharacter(indexOfChar: Int) -> Character {
        
        let product = self
        
        guard let objectId = product.objectId else {
            return Character("z")
        }
        
        let minCount = min(objectId.characters.count, objectId.characters.count)
        let charIndex = indexOfChar % minCount
        return Array(objectId.characters)[charIndex]
    }
}

extension ProductsResponse {
    
    /**
    Will order and shuffle following this rules:
    - First group by distances (<1mi, 1-2mi, 2-3mi, ..., 19-20mi, >20mi)
    - Then group by freshness (<72h, 72h-168h, >168h) [exception: no sold objects in first group]
    - Then shuffle inside freshness group by ordering using character in productId
    
    - parameter location: location that was used to get the product list
    - returns: Shuffled array of Product
    */
    public func shuffledProducts(location: LGLocationCoordinates2D) -> [Product] {
        return shuffledProducts(location.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision))
    }
    
    /**
    Will order and shuffle following this rules:
    - First group by distances (<1mi, 1-2mi, 2-3mi, ..., 19-20mi, >20mi)
    - Then group by freshness (<72h, 72h-168h, >168h) [exception: no sold objects in first group]
    - Then shuffle inside freshness group by ordering using character in productId
    
    - parameter quadKey: quadKey that was used to get the product list
    - returns: Shuffled array of Product
    */
    public func shuffledProducts(quadKey: String) -> [Product] {
        
        //Retrieving quadkey center
        let quadKeyCenter = LGLocationCoordinates2D(fromCenterOfQuadKey: quadKey)
        let queryLocation = CLLocation(latitude: quadKeyCenter.latitude, longitude: quadKeyCenter.longitude)
        
        //Used to select pseudo-random char from productId
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let myComponents = myCalendar!.components(.Day, fromDate: todayDate)
        let monthDay = myComponents.day

        
        func sortFunc(product1 : Product, product2 : Product) -> Bool {
            
            //Sort by groups of distance
            let product1Distance = product1.groupOfDistance(queryLocation)
            let product2Distance = product2.groupOfDistance(queryLocation)
            if(product1Distance != product2Distance){
                return product1Distance < product2Distance
            }
            
            //If equal distance sort by groups of freshness
            let product1Freshness = product1.groupOfFreshness(todayDate)
            let product2Freshness = product2.groupOfFreshness(todayDate)
            if(product1Freshness != product2Freshness){
                return product1Freshness < product2Freshness
            }
            
            //If equal freshness sort by productId character
            let product1Char = product1.shuffledCharacter(monthDay)
            let product2Char = product2.shuffledCharacter(monthDay)
            
            return product1Char < product2Char
        }
        
        return self.products.sort(sortFunc)
    }
    
}
