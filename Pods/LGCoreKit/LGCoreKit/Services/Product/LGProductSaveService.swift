//
//  LGProductSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 27/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

final public class LGProductSaveService: ProductSaveService {

    public func saveProduct(product: Product, forUser user: User, sessionToken: String, completion: ProductSaveServiceCompletion?) {
        
        let params = parametersForSaveProduct(product, user: user).letgoApiParams
        var request: URLRequestAuthenticable

        if let idProduct = product.objectId {
            request = ProductRouter.Update(productId: idProduct, params: params)
        } else {
            request = ProductRouter.Create(params: params)
        }
        
        ApiClient.request(request, decoder: LGProductSaveService.decoder) { (result: Result<Product, ApiError>) -> () in
            if let value = result.value {
                completion?(ProductSaveServiceResult(value: value))
            } else if let error = result.error {
                completion?(ProductSaveServiceResult(error: ProductSaveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> Product? {
        let product: LGProduct? = decode(object)
        return product
    }

    private func parametersForSaveProduct(product: Product, user: User) -> SaveProductParams {
        
        var params = SaveProductParams()
        
        if let name = product.name {
            params.name = name
        }
        
        params.category = String(product.category.rawValue)

        if let languageCode = product.languageCode {
            params.languageCode = languageCode
        }

        if let userId = user.objectId {
            params.userId = userId
        }

        if let description = product.descr {
            params.descr = description
        }

        if let price = product.price {
            params.price = String(price)
        }

        if let currency = product.currency?.code {
            params.currency = currency
        }

        params.latitude = String(format:"%f", product.location.latitude)

        params.longitude = String(format:"%f", product.location.longitude)

        if let countryCode = product.postalAddress.countryCode {
            params.countryCode = countryCode
        }

        if let city = product.postalAddress.city {
            params.city = city
        }

        if let address = product.postalAddress.address {
            params.address = address
        }

        if let zipCode = product.postalAddress.zipCode {
            params.zipCode = zipCode
        }

        if !product.images.isEmpty {
            var tokensArray : [String] = []
            
            for image in product.images {
                if let token = image.objectId {
                    tokensArray.append(token)
                }
            }
            
            params.images = tokensArray
        }
        
        return params
        
    }

}

extension SaveProductParams {
    var letgoApiParams: Dictionary<String, AnyObject> {
        get {
            var params = Dictionary<String, AnyObject>()
            if let name = self.name {
                params["name"] = name
            }

            if let category = self.category {
                params["category"] = category
            }
            
            if let languageCode = self.languageCode{
                params["languageCode"] = languageCode
            }
            
            if let userId = self.userId {
                params["userId"] = userId
            }
            
            if let description = self.descr {
                params["description"] = description
            }
            
            if let price = self.price {
                params["price"] = price
            }
            
            if let currency = self.currency {
                params["currency"] = currency
            }
            
            if let latitude = self.latitude {
                params["latitude"] = latitude
            }
            
            if let longitude = self.longitude {
                params["longitude"] = longitude
            }
            
            if let countryCode = self.countryCode {
                params["countryCode"] = countryCode
            }
            
            if let city = self.city {
                params["city"] = city
            }
            
            if let address = self.address {
                params["address"] = address
            }
            
            if let zipCode = self.zipCode {
                params["zipCode"] = zipCode
            }
            
            if let images = self.images {
                
                
                var imageTokensArrayString = "["
                var i = 0
                
                while i < images.count {
                    imageTokensArrayString += "\"" + images[i] + "\""
                    if i < images.count - 1 {
                        imageTokensArrayString += ","
                    }
                    i++
                }
                imageTokensArrayString += "]"
                params["images"] = imageTokensArrayString
                
            }
                        
            return params
        }
    }
}