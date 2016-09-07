//
//  CustomParsers.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 29/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import CoreLocation
import Foundation


public class LGArgo {

    public static func mandatoryWithFallback <A where A: Decodable, A == A.DecodedType>(json json: JSON, key: String, fallback: A) -> Decoded<A> {
        let result : Decoded<A> = json <| key

        switch result {
            case .Success: return result
            case .Failure: return .Success(fallback)
        }
    }

    public static func jsonToCoordinates(input: JSON) -> Decoded<LGLocationCoordinates2D?> {
        guard let latitude: Double = input.decode("latitude"), longitude: Double = input.decode("longitude") else {
            return Decoded<LGLocationCoordinates2D?>.Success(nil)
        }
        return Decoded<LGLocationCoordinates2D?>.Success(LGLocationCoordinates2D(latitude: latitude, longitude: longitude))
    }

    public static func jsonToCoordinates(input: JSON?, latKey: String, lonKey: String) -> Decoded<LGLocationCoordinates2D> {
        guard let jsonInput = input else {
            return Decoded<LGLocationCoordinates2D>.customError("Missing Json input")
        }

        guard let latitude: Double = jsonInput.decode(latKey) else {
            return Decoded<LGLocationCoordinates2D>.missingKey(latKey)
        }
        guard let longitude: Double = jsonInput.decode(lonKey) else{
            return Decoded<LGLocationCoordinates2D>.missingKey(lonKey)
        }

        return Decoded<LGLocationCoordinates2D>.Success(LGLocationCoordinates2D(latitude: latitude, longitude: longitude))
    }

    public static func jsonToLocation(json: JSON, latKey: String, lonKey: String, typeKey: String) -> Decoded<LGLocation?> {
        guard let latitude: Double = json.decode(latKey) else { return Decoded<LGLocation?>.Success(nil) }
        guard let longitude: Double = json.decode(lonKey) else { return Decoded<LGLocation?>.Success(nil) }
        let locationTypeString: String = json.decode(typeKey) ?? ""
        let locationType = LGLocationType(rawValue: locationTypeString)

        let clLocation = CLLocation(latitude: latitude, longitude: longitude)
        let location = LGLocation(location: clLocation, type: locationType)
        return Decoded<LGLocation?>.Success(location)
    }

    public static func jsonToAvatarFile(input: JSON, avatarKey: String) -> Decoded<LGFile?> {
        guard let fileUrl: String = input.decode(avatarKey) else {
            return Decoded<LGFile?>.Success(nil)
        }
        return Decoded<LGFile?>.Success(LGFile(id: nil, urlString: fileUrl))
    }
    
    public static func jsonToCurrency(input: JSON, currencyKey: [String]) -> Decoded<Currency> {
        guard let currencyCode: String = input.decode(currencyKey) else {
            return Decoded<Currency>.Success(LGCoreKitConstants.defaultCurrency)
        }
        return Decoded<Currency>.Success(Currency.currencyWithCode(currencyCode))
    }

    public static func jsonArrayToFileArray(input: [JSON]?) -> Decoded<[LGFile]> {
        var result : [LGFile] = []
        guard let arrayInput = input else {
            return Decoded<[LGFile]>.Success(result)
        }

        arrayInput.forEach {
            guard let objectId: String = $0.decode("id") else { return }
            guard let fileUrl: String = $0.decode("url") else { return }
            result.append(LGFile(id: objectId, urlString: fileUrl))
        }
        return Decoded<[LGFile]>.Success(result)
    }
    
    public static func parseChatMessageType(json: JSON, key: [String]) -> Decoded<ChatMessageType> {
        guard let raw: String = json.decode(key), type = ChatMessageType(rawValue: raw) else {
            return Decoded<ChatMessageType>.Success(.Text)
        }
        return Decoded<ChatMessageType>.Success(type)
    }
    
    public static func parseCommercializerStatus(json: JSON, key: String) -> Decoded<CommercializerStatus> {
        guard let raw: Int = json.decode(key), status = CommercializerStatus(rawValue: raw) else {
            return Decoded<CommercializerStatus>.Success(.Unavailable)
        }
        return Decoded<CommercializerStatus>.Success(status)
    }
}
