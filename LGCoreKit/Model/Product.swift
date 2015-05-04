//
//  Product.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Foundation

@objc protocol Product: BaseModel {
    var address: String? { get set }
    var category: NSNumber? { get set }
    var categoryId: NSNumber? { get set }
    var city: String? { get set }
    var countryCode: String? { get set }
    var currency: String? { get set }
    var descr: String? { get set }
    var gpsCoordinates: CLLocationCoordinate2D { get set }
    var image0URL: String { get }
    var image1URL: String { get }
    var image2URL: String { get }
    var image3URL: String { get }
    var image4URL: String { get }
    var image5URL: String { get }
    var languageCode: String? { get set }
    var name: String? { get set }
    var nameDirify: String? { get set }
    var price: NSNumber? { get set }
    var isThumbnailProcessed: NSNumber? { get set }
    var status: NSNumber? { get set }
    var type: NSNumber? { get set }
    var userId: NSNumber? { get set }
    var zipCode: String? { get set }
    
    func retrieveImage0AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage1AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage2AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage3AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage4AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage5AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
}