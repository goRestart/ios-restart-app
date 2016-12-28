//
//  LetgoURLHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 14/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import DeviceUtil

class LetgoURLHelper {
    private static let langsCountryDict = [
        "de":"de",  // https://de.letgo.com/de/something
        "el":"gr",  // https://gr.letgo.com/el/something
        "en":"us",  // https://us.letgo.com/en/something
        "es":"es",  // https://es.letgo.com/es/something
        "fi":"fi",  // https://fi.letgo.com/fi/something
        "fr":"fr",  // https://fr.letgo.com/fr/something
        "hu":"hu",  // https://hu.letgo.com/hu/something
        "it":"it",  // https://it.letgo.com/it/something
        "nb":"no",  // https://no.letgo.com/nb/something
        "nl":"nl",  // https://nl.letgo.com/nl/something
        "ru":"ru",  // https://ru.letgo.com/ru/something
        "sv":"se",  // https://se.letgo.com/sv/something
        "tr":"tr",  // https://tr.letgo.com/tr/something
        "vi":"vn",  // https://vn.letgo.com/vi/something
        "pt":"pt",  // https://pt.letgo.com/pt/something
        "ko":"kr"   // https://kr.letgo.com/ko/something
    ]
    private static let defaultLang = "en"
    private static let defaultCountry = "us"

    static func composeURL(baseUrl: String, preferredLanguage: String? = nil) -> NSURL? {
        let prefLanguage = preferredLanguage ?? systemLanguage()

        var language = LetgoURLHelper.defaultLang
        var country = LetgoURLHelper.defaultCountry
        if let preferredCountry = LetgoURLHelper.langsCountryDict[prefLanguage] {
            language = prefLanguage
            country = preferredCountry
        }
        let urlString = String(format: baseUrl, arguments: [country, language])
        return NSURL(string: urlString)
    }

    private static func systemLanguage() -> String {
        let preferredLanguages = NSLocale.preferredLanguages()
        guard !preferredLanguages.isEmpty else { return LetgoURLHelper.defaultLang }

        for preferredLanguage in preferredLanguages {
            // In case it's like es-ES, just take the first "es"
            let components = preferredLanguage.componentsSeparatedByString("-")
            guard let lang = components.first else { continue }
            guard let _ = langsCountryDict[lang] else { continue }
            return lang.lowercaseString
        }
        return LetgoURLHelper.defaultLang
    }

    static func buildRecaptchaURL(transparent transparent: Bool) -> NSURL? {
        guard let url = LetgoURLHelper.composeURL(Constants.helpURL) else { return nil }
        guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildRecaptchParameters(transparent)
        return urlComponents.URL
    }

    static func buildHelpURL(user: MyUser?, installation: Installation?) -> NSURL? {
        guard let  url = LetgoURLHelper.composeURL(Constants.helpURL) else { return nil }
        guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(user, installation: installation,
                                                                                  moderation: false)
        return urlComponents.URL
    }

    static func buildContactUsURL(user user: MyUser?, installation: Installation?, moderation: Bool = false) -> NSURL? {
        guard let  url = LetgoURLHelper.composeURL(Constants.contactUs) else { return nil }
        guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(user, installation: installation,
                                                                                  moderation: moderation)
        return urlComponents.URL
    }

    static func buildContactUsURL(userEmail email: String?, installation: Installation?, moderation: Bool = false) -> NSURL? {
        guard let  url = LetgoURLHelper.composeURL(Constants.contactUs) else { return nil }
        guard let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(nil, userName: nil, email: email,
                                                                                  installationId: installation?.objectId,
                                                                                  moderation: moderation)
        return urlComponents.URL
    }

    private static func buildContactParameters(user: MyUser?, installation: Installation?, moderation: Bool) -> String? {
        return buildContactParameters(user?.objectId, userName: user?.name, email: user?.email,
                                      installationId: installation?.objectId, moderation: moderation)
    }
    
    private static func buildContactParameters(userId: String?, userName: String?, email: String?, installationId: String?
        , moderation: Bool) -> String? {
        var param: [String: String] = [:]
        param["app_version"] = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        param["os_version"] = UIDevice.currentDevice().systemVersion
        param["device_model"] = DeviceUtil.hardwareDescription()
        param["user_id"] = userId
        param["user_name"] = userName
        param["user_email"] = email
        param["installation_id"] = installationId
        if moderation {
            param["moderation"] = "true"
        }
        return param.map{"\($0)=\($1)"}
            .joinWithSeparator("&")
            .encodeString()
    }

    private static func buildRecaptchParameters(transparent: Bool) -> String {
        let value = transparent ? "true": "false"
        return "\transparent=\(value)"
    }
}
