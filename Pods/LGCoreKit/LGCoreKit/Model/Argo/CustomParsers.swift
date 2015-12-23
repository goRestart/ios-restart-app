//
//  CustomParsers.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 29/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

import Argo

public class LGArgo{
    
    public static func mandatoryWithFallback <A where A: Decodable, A == A.DecodedType>(json json: JSON, key: String, fallback: A) -> Decoded<A> {
        let result : Decoded<A> = json <| key
        
        switch result {
            case .Success: return result
            case .Failure: return .Success(fallback)
        }
    }
    
    public static func parseDate(json json: JSON, key: String) -> Decoded<NSDate?> {
        let result : Decoded<String> = json <| key
        switch result {
            case let .Success(value): return Decoded<NSDate>.fromOptional(LGDateFormatter.sharedInstance.dateFromString(value))
            case .Failure(.MissingKey): return Decoded<NSDate>.optional(Decoded<NSDate>.missingKey(key))
            case let .Failure(.TypeMismatch(x)): return .Failure(.TypeMismatch(x))
            case let .Failure(.Custom(x)): return .Failure(.Custom(x))
        }
    }
    
    public static func jsonToCoordinates(input: JSON?, latKey: String, lonKey: String) -> Decoded<LGLocationCoordinates2D> {
        guard let jsonInput = input else {
            return Decoded<LGLocationCoordinates2D>.customError("Missing Json input")
        }
        
        guard let latitude : Double = jsonInput <| latKey else{
            return Decoded<LGLocationCoordinates2D>.missingKey(latKey)
        }
        guard let longitude : Double = jsonInput <| lonKey else{
            return Decoded<LGLocationCoordinates2D>.missingKey(lonKey)
        }
        
        return Decoded<LGLocationCoordinates2D>.Success(LGLocationCoordinates2D(latitude: latitude, longitude: longitude))
    }
    
    public static func jsonArrayToFileArray(input: [JSON]?) -> Decoded<[LGFile]> {
        
        var result : [LGFile] = []
        
        guard let arrayInput = input else {
            return Decoded<[LGFile]>.Success(result)
        }
        
        for jsonFile in arrayInput {
            let objectId : String? = jsonFile <| "id"
            let fileUrl : String? = jsonFile <| "url"
            result.append(LGFile(id: objectId, urlString: fileUrl))
        }
        
        return Decoded<[LGFile]>.Success(result)
    }
}