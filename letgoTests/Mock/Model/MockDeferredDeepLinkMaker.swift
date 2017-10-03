//
//  MockDeferredDeepLinkMaker.swift
//  LetGo
//
//  Created by Facundo Menzella on 28/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class MockDeferredDeepLinkMaker {

    static func makeTargetFail() -> [String: Any]? {
        return nil
    }

    static func makeFacebookTargetQuery(_ queryString: String) -> [String: Any]? {
        var installData: [String: Any]? = [:]
        if let installJSON = Bundle.main.url(forResource: "DeferredDeepLinkFacebookTargetSearchQuery", withExtension: "json") {
            do {
                let data = try Data(contentsOf: installJSON)
                var jsonString: String = String(data: data, encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "{0}",
                                                             with: queryString,
                                                             options: .literal,
                                                             range: nil)

                installData = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!,
                                                               options: []) as? [String: Any]
            } catch {
                return installData
            }
        }
        return installData
    }

    static func makeTargetQuery(_ queryString: String) -> [String: Any]? {
        var installData: [String: Any]? = [:]
        if let installJSON = Bundle.main.url(forResource: "DeferredDeepLinkTargetSearchQuery", withExtension: "json") {
            do {
                let data = try Data(contentsOf: installJSON)
                var jsonString: String = String(data: data, encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "{0}",
                                                             with: queryString,
                                                             options: .literal,
                                                             range: nil)

                installData = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!,
                                                               options: []) as? [String: Any]
            } catch {
                return installData
            }
        }
        return installData
    }

    static func makeFacebookTargetCategory(_ categoryID: String) -> [String: Any]? {
        var installData: [String: Any]? = [:]
        if let installJSON = Bundle.main.url(forResource: "DeferredDeepLinkFacebookTargetCategory", withExtension: "json") {
            do {
                let data = try Data(contentsOf: installJSON)
                var jsonString: String = String(data: data, encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "{0}",
                                                             with: categoryID,
                                                             options: .literal,
                                                             range: nil)

                installData = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!,
                                                               options: []) as? [String: Any]
            } catch {
                return installData
            }
        }
        return installData
    }

    static func makeTargetCategory(_ categoryID: String) -> [String: Any]? {
        var installData: [String: Any]? = [:]
        if let installJSON = Bundle.main.url(forResource: "DeferredDeepLinkTargetCategory", withExtension: "json") {
            do {
                let data = try Data(contentsOf: installJSON)
                var jsonString: String = String(data: data, encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "{0}",
                                                             with: categoryID,
                                                             options: .literal,
                                                             range: nil)

                installData = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!,
                                                               options: []) as? [String: Any]
            } catch {
                return installData
            }
        }
        return installData
    }

    static func makeFacebookTargetListing(_ listingID: String) -> [String: Any]? {
        var installData: [String: Any]? = [:]
        if let installJSON = Bundle.main.url(forResource: "DeferredDeepLinkFacebookTargetListing", withExtension: "json") {
            do {
                let data = try Data(contentsOf: installJSON)
                var jsonString: String = String(data: data, encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "{0}",
                                                             with: listingID,
                                                             options: .literal,
                                                             range: nil)
                installData = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!,
                                                               options: []) as? [String: Any]
            } catch {
                return installData
            }
        }
        return installData
    }

    static func makeTargetListing(_ listingID: String) -> [String: Any]? {
        var installData: [String: Any]? = [:]
        if let installJSON = Bundle.main.url(forResource: "DeferredDeepLinkTargetListing", withExtension: "json") {
            do {
                let data = try Data(contentsOf: installJSON)
                var jsonString: String = String(data: data, encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "{0}",
                                                             with: listingID,
                                                             options: .literal,
                                                             range: nil)
                installData = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!,
                                                               options: []) as? [String: Any]
            } catch {
                return installData
            }
        }
        return installData
    }
    
}
