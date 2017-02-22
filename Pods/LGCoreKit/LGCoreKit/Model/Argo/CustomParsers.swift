//
//  CustomParsers.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 29/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import CoreLocation

class LGArgo {

    static func mandatoryWithFallback <A>(json: JSON, key: String, fallback: A) -> Decoded<A> where A: Decodable, A == A.DecodedType {
        let result : Decoded<A> = json <| key

        switch result {
            case .success: return result
            case .failure: return .success(fallback)
        }
    }

    static func jsonToCoordinates(_ input: JSON) -> Decoded<LGLocationCoordinates2D?> {
        guard let latitude: Double = input.decode("latitude"), let longitude: Double = input.decode("longitude") else {
            return Decoded<LGLocationCoordinates2D?>.success(nil)
        }
        return Decoded<LGLocationCoordinates2D?>.success(LGLocationCoordinates2D(latitude: latitude, longitude: longitude))
    }

    static func jsonToCoordinates(_ input: JSON?, latKey: String, lonKey: String) -> Decoded<LGLocationCoordinates2D> {
        guard let jsonInput = input else {
            return Decoded<LGLocationCoordinates2D>.customError("Missing Json input")
        }

        guard let latitude: Double = jsonInput.decode(latKey) else {
            return Decoded<LGLocationCoordinates2D>.missingKey(latKey)
        }
        guard let longitude: Double = jsonInput.decode(lonKey) else{
            return Decoded<LGLocationCoordinates2D>.missingKey(lonKey)
        }

        return Decoded<LGLocationCoordinates2D>.success(LGLocationCoordinates2D(latitude: latitude, longitude: longitude))
    }

    static func jsonToLocation(_ json: JSON, latKey: String, lonKey: String, typeKey: String) -> Decoded<LGLocation?> {
        guard let latitude: Double = json.decode(latKey) else { return Decoded<LGLocation?>.success(nil) }
        guard let longitude: Double = json.decode(lonKey) else { return Decoded<LGLocation?>.success(nil) }
        let locationTypeString: String = json.decode(typeKey) ?? ""
        let locationType = LGLocationType(rawValue: locationTypeString) ?? .regional

        let clLocation = CLLocation(latitude: latitude, longitude: longitude)
        let postalAddress = PostalAddress.decode(json).value
        let location = LGLocation(location: clLocation, type: locationType, postalAddress: postalAddress)
        return Decoded<LGLocation?>.success(location)
    }

    static func jsonToAvatarFile(_ input: JSON, avatarKey: String) -> Decoded<LGFile?> {
        guard let fileUrl: String = input.decode(avatarKey) else {
            return Decoded<LGFile?>.success(nil)
        }
        return Decoded<LGFile?>.success(LGFile(id: nil, urlString: fileUrl))
    }
    
    static func jsonToCurrency(_ input: JSON, currencyKey: [String]) -> Decoded<Currency> {
        guard let currencyCode: String = input.decode(currencyKey) else {
            return Decoded<Currency>.success(LGCoreKitConstants.defaultCurrency)
        }
        return Decoded<Currency>.success(Currency.currencyWithCode(currencyCode))
    }

    static func jsonArrayToFileArray(_ input: [JSON]?) -> Decoded<[LGFile]> {
        var result : [LGFile] = []
        guard let arrayInput = input else {
            return Decoded<[LGFile]>.success(result)
        }

        arrayInput.forEach {
            guard let objectId: String = $0.decode("id") else { return }
            guard let fileUrl: String = $0.decode("url") else { return }
            result.append(LGFile(id: objectId, urlString: fileUrl))
        }
        return Decoded<[LGFile]>.success(result)
    }
    
    static func parseChatMessageType(_ json: JSON, key: [String]) -> Decoded<ChatMessageType> {
        guard let raw: String = json.decode(key), let type = ChatMessageType(rawValue: raw) else {
            return Decoded<ChatMessageType>.success(.text)
        }
        return Decoded<ChatMessageType>.success(type)
    }
    
    static func parseCommercializerStatus(_ json: JSON, key: String) -> Decoded<CommercializerStatus> {
        guard let raw: Int = json.decode(key), let status = CommercializerStatus(rawValue: raw) else {
            return Decoded<CommercializerStatus>.success(.unavailable)
        }
        return Decoded<CommercializerStatus>.success(status)
    }
}
