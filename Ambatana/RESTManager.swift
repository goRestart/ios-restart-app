//
//  RESTManager.swift
//  LetGo
//
//  Created by Nacho on 13/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import UIKit

// private singleton instance
private let _singletonInstance = RESTManager()

// API global constants

// Note: using old endpoint cos' oauth is not in place
//let kLetGoRestAPIBaseURL                            = "http://api.letgo.com"          // new PROD
let kLetGoRestAPIBaseURL                            = "http://3rdparty.ambatana.com"    // old PROD
//let kLetGoRestAPIBaseURL                            = "http://devel.api.letgo.com"      // new DEV
//let kLetGoRestAPIBaseURL                            = "http://vps122602.ovh.net"      // old DEV

private let kLetGoRestAPIEndpoint                           = "/api"
private let kLetGoRestAPIImagesPath                         = "/images"
private let kLetGoRestAPIJSONFormatSuffix                   = ".json"
private let kLetGoRestAPIPathSeparator                      = "/"

// API endpoint URLs
private let kLetGoRestAPIListItemsURL                       = "/list"
private let kLetGoRestAPILocationsURL                       = "/locations"
private let kLetGoRestAPILocationDetailsURL                 = "/details"
private let kLetGoRestAPIProductDataURL                     = "/products"
private let kLetGoRestAPIUpdateProductURL                   = "/update"
private let kLetGoRestAPIRelatedProductURL                  = "/related/product"
private let kLetGoRestAPISynchronizeProductURL              = "/sincronizedb"
private let kLetGoRestAPIUsersURL                           = "/users"
private let kLetGoRestAPIIPLookupURL                        = "/iplookup"

// API parameters
private let kLetGoRestAPIParameterIPAddress                 = "?ip_address="

// API parameters
let kLetGoRestAPIParameterQueryString               = "query_string"
let kLetGoRestAPIParameterLatitude                  = "latitude"
let kLetGoRestAPIParameterLongitude                 = "longitude"
let kLetGoRestAPIParameterCategoryId                = "category_id"
let kLetGoRestAPIParameterSortBy                    = "sort_by"
let kLetGoRestAPIParameterDistanceType              = "distance_type"
let kLetGoRestAPIParameterOffset                    = "offset"
let kLetGoRestAPIParameterNumberOfProducts          = "nr_products"
let kLetGoRestAPIParameterDefaultNumberOfProducts   = 20
let kLetGoRestAPIParameterStatus                    = "status"
let kLetGoRestAPIParameterMaxPrice                  = "max_price"
let kLetGoRestAPIParameterMinPrice                  = "min_price"
let kLetGoRestAPIParameterDistanceRadius            = "distance_radius"
let kLetGoRestAPIParameterUserObjectId              = "user_object_id"
let kLetGoRestAPIParameterFullObjectData            = "full"
let kLetGoRestAPIParameterObjectId                  = "object_id"
let kLetGoRestAPIParameterProductId                 = "product_id"
let kLetGoRestAPIParameterName                      = "name"
let kLetGoRestAPIParameterPrice                     = "price"
let kLetGoRestAPIParameterCurrency                  = "currency"
let kLetGoRestAPIParameterCreatedAt                 = "created_at"
let kLetGoRestAPIParameterImgURLThumb               = "img_url_thumb"
let kLetGoRestAPIParameterDistance                  = "distance"
let kLetGoRestAPIParameterImageDimensions           = "image_dimensions"
let kLetGoRestAPIParameterWidth                     = "width"
let kLetGoRestAPIParameterHeight                    = "height"

let kLetGoRestAPIParameterProductDescription        = "description"
let kLetGoRestAPIParameterCity                      = "city"
let kLetGoRestAPIParameterCountryCode               = "country_code"
let kLetGoRestAPIParameterCountryCodeAlt            = "country_code3"
let kLetGoRestAPIParameterCountryName               = "country_name"
let kLetGoRestAPIParameterContinentCode             = "continent_code"
let kLetGoRestAPIParameterNameDirify                = "name_dirify"
let kLetGoRestAPIParameterLanguageCode              = "language_code"
let kLetGoRestAPIParameterUserId                    = "user_id"
let kLetGoRestAPIParameterInitialImage              = "image0"
let kLetGoRestAPIParameterInitialThumb              = "image0_thumb"
let kLetGoRestAPIParameterProduct                   = "product"
let kLetGoRestAPIParameterData                      = "data"
let kLetGoRestAPIParameterImages                    = "images"
let kLetGoRestAPIParameterImageOriginal             = "original"
let kLetGoRestAPIParameterImageThumb                = "thumb"
let kLetGoRestAPIParameterShortName                 = "short_name"
let kLetGoRestAPIParameterLongName                  = "long_name"
let kLetGoRestAPIParameterTypes                     = "types"
let kLetGoRestAPIParameterFormatedAddress           = "formated_address"
let kLetGoRestAPIParameterGeometry                  = "geometry"
let kLetGoRestAPIParameterLocation                  = "location"
let kLetGoRestAPIParameterAddressComponents         = "address_components"
let kLetGoRestAPIParameterPlaceId                   = "place_id"
let kLetGoRestAPIParameterReference                 = "reference"
let kLetGoRestAPIParameterVicinity                  = "vicinity"
let kLetGoRestAPIParameterURL                       = "url"
let kLetGoRestAPIParameterResult                    = "result"
let kLetGoRestAPIParameterPredictions               = "predictions"

// misc
let kLetGoRestAPIPredictionResultOK                 = "OK"
let kLetGoRestAPIPredictionResultZeroResults        = "ZERO_RESULTS"
let kLetGoRestAPIPredictionResultInvalidRequest     = "INVALID_REQUEST"
let kLetGoRestAPISynchronizeProductMaxAttempts      = 3

// ordering strings
let kLetGoRestAPIOrderByMinPrice                    = "price asc"
let kLetGoRestAPIOrderByMaxPrice                    = "price desc"
let kLetGoRestAPIOrderByProximity                   = "location desc"
let kLetGoRestAPIOrderByCreationDate                = ""


/** 
 * The class RESTManager is in charge of managing all communications with the REST API of LetGo.
 * RESTManager uses the Singleton design pattern, so it must be instanciated and used through sharedInstance by calling RESTManager.sharedInstance()
 */
class RESTManager: NSObject {
    // data
    var restDispatchQueue: dispatch_queue_t

    // MARK: - LifeCycle
    
    override init() {
        if iOSVersionAtLeast("8.0") {
            let queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
            restDispatchQueue = dispatch_queue_create("com.letgo.LetGoRESTManagerQueue", queueAttributes)
        } else { restDispatchQueue = dispatch_queue_create("com.letgo.LetGoRESTManagerQueue", DISPATCH_QUEUE_SERIAL) }
        super.init()
    }
    
    /** Shared instance */
    class var sharedInstance: RESTManager {
        return _singletonInstance
    }

    // MARK: - Product requests.
    
    /**
     * Requests a list of products to the backend and calls the completion handler. On success, returns an array of LetGoProduct instances.
     */
    func getListOfProducts(queryString: String?, location: CLLocationCoordinate2D, categoryId: LetGoProductCategory?, sortBy: LetGoUserFilterForProducts, offset: Int, status: [LetGoProductStatus]?, maxPrice: Int?, distanceRadius: Int?, minPrice: Int?, fromUser: String?, completion: ((success: Bool, products: [LetGoProduct]?, retrievedItems: Int, successfullyParsedItems: Int) -> Void)?) -> Void {
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPIListItemsURL + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            // build list request parameters
            var parameters: [String: AnyObject] = [kLetGoRestAPIParameterNumberOfProducts:kLetGoRestAPIParameterDefaultNumberOfProducts]
            if queryString != nil { parameters[kLetGoRestAPIParameterQueryString] = queryString! }
            if CLLocationCoordinate2DIsValid(location) {
                parameters[kLetGoRestAPIParameterLatitude] = location.latitude
                parameters[kLetGoRestAPIParameterLongitude] = location.longitude
            }
            if categoryId != nil { parameters[kLetGoRestAPIParameterCategoryId] = categoryId!.rawValue }
            if let sortByParameter = sortBy.filterStringForRestAPI() { parameters[kLetGoRestAPIParameterSortBy] = sortByParameter }
            parameters[kLetGoRestAPIParameterDistanceType] = LetGoDistanceMeasurementSystem.retrieveCurrentDistanceMeasurementSystem().distanceMeasurementStringForRestAPI()
            parameters[kLetGoRestAPIParameterOffset] = offset
            if status?.count > 0 { parameters[kLetGoRestAPIParameterStatus] = ",".join(status!.map { $0.description }) }
            if maxPrice != nil { parameters[kLetGoRestAPIParameterMaxPrice] = maxPrice! }
            if minPrice != nil { parameters[kLetGoRestAPIParameterMinPrice] = minPrice! }
            if distanceRadius != nil { parameters[kLetGoRestAPIParameterDistanceRadius] = distanceRadius }
            if fromUser != nil { parameters[kLetGoRestAPIParameterUserObjectId] = fromUser! }
            
            // perform request.
            request(.GET, url, parameters: parameters).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                if (error != nil) { // request failed
                    completion?(success: false, products: nil, retrievedItems: 0, successfullyParsedItems: 0)
                } else { // success. Analyze response.
                    if let jsonDict = json as? [String: AnyObject] {
                        if let productsData = jsonDict[kLetGoRestAPIParameterData] as? [[String: AnyObject]] {
                            var products: [LetGoProduct] = []
                            for productData in productsData {
                                if let newProduct = LetGoProduct(valuesFromProductInListDictionary: productData, loadThumbnailImage: false) {
                                    products.append(newProduct)
                                }
                            }
                            completion?(success: true, products: products, retrievedItems: productsData.count, successfullyParsedItems: products.count)
                            return
                        }
                    }
                    completion?(success: false, products: nil, retrievedItems: 0, successfullyParsedItems: 0)
                }
            })
        } else { completion?(success: false, products: nil, retrievedItems: 0, successfullyParsedItems: 0) }
    }
    
    /** Request data about a concrete product based on product id */
    func retrieveProductWithId(productId: String, completion: ((success: Bool, product: LetGoProduct?) -> Void)? ) -> Void {
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPIProductDataURL + kLetGoRestAPIPathSeparator + productId + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            // build parameters (request full object with all images in an array)
            let parameters = [kLetGoRestAPIParameterFullObjectData: "true"]
            
            // perform request
            request(.GET, url, parameters: parameters).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                if (error != nil) { // request failed
                    completion?(success: false, product: nil)
                } else { // success. Analyze response.
                    if let jsonDict = json as? [String: AnyObject] {
                        if let productData = jsonDict[kLetGoRestAPIParameterData] as? [String: AnyObject] {
                            if let newProduct = LetGoProduct(valuesFromFullProductDictionary: productData, loadImages: false) {
                                completion?(success: true, product: newProduct)
                                return
                            }
                        }
                    }
                    completion?(success: false, product: nil)
                }
            })
        } else { completion?(success: false, product: nil) }
    }
    
    /** Retrieves the products related to a product with a given id */
    func retrieveProductsRelatedToProductWithId(productId: String, offset: Int, distance_type: LetGoDistanceMeasurementSystem?, completion: ((success: Bool, products: [LetGoProduct]?) -> Void)? ) -> Void {
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPIRelatedProductURL + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            // build parameters (request full object with all images in an array)
            let parameters: [String: AnyObject] = [
                kLetGoRestAPIParameterOffset: offset,
                kLetGoRestAPIParameterDistanceType: LetGoDistanceMeasurementSystem.retrieveCurrentDistanceMeasurementSystem().distanceMeasurementStringForRestAPI()
            ]
            
            // perform request
            request(.GET, url, parameters: parameters).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                if (error != nil) { // request failed
                    completion?(success: false, products: nil)
                } else { // success. Analyze response.
                    if let jsonDict = json as? [String: AnyObject] {
                        if let productsData = jsonDict[kLetGoRestAPIParameterData] as? [[String: AnyObject]] {
                            var products: [LetGoProduct] = []
                            for productData in productsData {
                                if let product = LetGoProduct(valuesFromProductInListDictionary: productData, loadThumbnailImage: false) { products.append(product) }
                            }
                            completion?(success: true, products: products)
                            return
                        }
                    }
                    completion?(success: false, products: nil)
                }
            })
        } else { completion?(success: false, products: nil) }
    }
    
    // MARK: - Update and synchronization of products
    
    /** Synchronizes a product created in Parse to the LetGo backend */
    func synchronizeProductFromParse(parseObjectId: String, attempt: Int, completion: ((success: Bool) -> Void)? ) -> Void {
        // max attempts reached?
        if attempt > kLetGoRestAPISynchronizeProductMaxAttempts { completion?(success: false) }
        
        // build URL request.
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPISynchronizeProductURL + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            request(.GET, url, parameters: nil).response({ (request, response, data, error) -> Void in
                if error == nil && (response?.statusCode >= 200 && response?.statusCode < 300) { // success
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion?(success: true)
                    })
                } else { // retry after one minute (up to three times).
                    dispatch_after(dispatchTimeForSeconds(60), self.restDispatchQueue, { () -> Void in
                        self.synchronizeProductFromParse(parseObjectId, attempt: (attempt+1), completion: completion)
                    })
                }
            })
        } else { completion?(success: false) }
    }
    
    // MARK: - GeoLocation requests
    
    /**
     * Requests a geolocation to the backend based on IP address. Returns a LetGoIPGeoLocation object.
     */
    func getGeoLocationBasedOnIPAddress(ipAddress: String, completion: ((success: Bool, geolocation: LetGoIPGeoLocation?) -> Void)? ) -> Void {
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPIIPLookupURL + kLetGoRestAPIJSONFormatSuffix + kLetGoRestAPIParameterIPAddress + ipAddress
        if let url = NSURL(string: urlString) {
            // perform request.
            request(.GET, url, parameters: nil).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                if (error != nil) { // request failed
                    completion?(success: false, geolocation: nil)
                } else { // success. Analyze response.
                    if let jsonDict = json as? [String: AnyObject] {
                        if let ipGeoLocation = LetGoIPGeoLocation(valuesFromDictionary: jsonDict) { completion?(success: true, geolocation: ipGeoLocation) }
                        else { completion?(success: false, geolocation: nil) }
                    } else { completion?(success: false, geolocation: nil) }
                }
            })
        } else { completion?(success: false, geolocation: nil) }
    }
    
    /**
     * Retrieves a prediction of the user location based on a location string.
     */
    func predictUserLocationBasedOnLocationString(locationString: String, completion: ((success: Bool, geolocation: LetGoGoogleGeoLocation?) -> Void)? ) -> Void {
        let encodedLocationString = locationString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) ?? locationString
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPILocationsURL + kLetGoRestAPIPathSeparator + encodedLocationString + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            // perform request.
            request(.GET, url, parameters: nil).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                if (error != nil) { // request failed
                    completion?(success: false, geolocation: nil)
                } else {
                    // A valid response will include at least one prediction with a place_id. We can use this place_id to perform a geolocation request to obtain the full LetGoGoogleGeoLocation object.
                    if let jsonDict = json as? [String: AnyObject] {
                        if let status = jsonDict[kLetGoRestAPIParameterStatus] as? String, resultData = jsonDict[kLetGoRestAPIParameterResult] as? [String: AnyObject] {
                            // check status first
                            if status.uppercaseString != kLetGoRestAPIPredictionResultOK { completion }
                            
                            // iterate through all predictions, trying to find one with a valid place_id to use.
                            if let predictions = jsonDict[kLetGoRestAPIParameterPredictions] as? [[String: AnyObject]] {
                                if predictions.count > 0 {
                                    for prediction in predictions { // for every prediction contained...
                                        if let predictionPlaceId = prediction[kLetGoRestAPIParameterPlaceId] as? String { // found a place_id, now retrieve geo location
                                            self.retrieveGeoLocationFromPlaceId(predictionPlaceId, completion: completion)
                                            return
                                        }
                                    }
                                }
                            }
                        }
                    }
                    completion?(success: false, geolocation: nil)
                }
            })
        } else { completion?(success: false, geolocation: nil) }
    }
    
    /** Retrieves a LetGoGoogleGeoLocation from a place_id. */
    func retrieveGeoLocationFromPlaceId(placeId: String, completion: ((success: Bool, geolocation: LetGoGoogleGeoLocation?) -> Void)? ) -> Void {
        let urlString = kLetGoRestAPIBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPILocationsURL + kLetGoRestAPILocationDetailsURL + kLetGoRestAPIPathSeparator + placeId + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            // perform request.
            request(.GET, url, parameters: nil).responseJSON(completionHandler: { (request, response, json, error) -> Void in
                if (error != nil) { // request failed
                    completion?(success: false, geolocation: nil)
                } else {
                    // Analyze response
                    if let jsonDict = json as? [String: AnyObject] {
                        if let status = jsonDict[kLetGoRestAPIParameterStatus] as? String, resultData = jsonDict[kLetGoRestAPIParameterResult] as? [String: AnyObject] {
                            if status.uppercaseString == kLetGoRestAPIPredictionResultOK {
                                if let retrievedGeoLocation = LetGoGoogleGeoLocation(valuesFromDictionary: resultData) {
                                    completion?(success: true, geolocation: retrievedGeoLocation)
                                    return
                                }
                            }
                        }
                    }
                    completion?(success: false, geolocation: nil)
                }
            })
        } else { completion?(success: false, geolocation: nil) }
    }

    // MARK: - Parse legacy methods
    func retrieveParseObjectWithId (parseObjectId: String, className: String, completion: ((success: Bool, parseObject: PFObject?) -> Void)? ) -> Void {
        let query = PFQuery(className: className)
        query.getObjectInBackgroundWithId(parseObjectId, block: { (parseObject, error) -> Void in
            if error == nil && parseObject != nil { completion?(success: true, parseObject: parseObject) }
            else { completion?(success: false, parseObject: nil) }
        })
    }
    
    func retrieveParseUserWithId (parseObjectId: String, completion: ((success: Bool, parseObject: PFUser?) -> Void)? ) -> Void {
        if let query = PFUser.query() {
            query.getObjectInBackgroundWithId(parseObjectId, block: { (userObject, error) -> Void in
                if let user = userObject as? PFUser { completion?(success: true, parseObject: user) }
                else { completion?(success: false, parseObject: nil) }
            })
        } else { completion?(success: false, parseObject: nil) }
    }
    
}


















