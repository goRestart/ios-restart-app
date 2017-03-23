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

enum ContactUsType {
    case standard
    case scammer
    case deviceNotAllowed
}

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

    private static var environment: AppEnvironment {
        return EnvironmentProxy.sharedInstance
    }


    // MARK: - Public methods

    static func buildHomeURLString() -> String {
        return environment.websiteBaseUrl   // not localized
    }

    static func buildHomeURL() -> URL? {
        return URL(string: buildHomeURLString())  // not localized
    }

    static func buildProductURL(productId: String) -> URL? {
        return URL(string: environment.websiteUrl(Constants.websiteProductEndpoint(productId)))   // not localized
    }

    static func buildUserURL(userId: String) -> URL? {
        return URL(string: environment.websiteUrl(Constants.websiteUserEndpoint(userId))) // not localized
    }

    static func buildRecaptchaURL(transparent: Bool) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(Constants.websiteRecaptchaEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildRecaptchParameters(transparent)
        return urlComponents.url
    }

    static func buildHelpURL(_ user: MyUser?, installation: Installation?) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(Constants.websiteHelpEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(user, installation: installation,
                                                                                  type: .standard)
        return urlComponents.url
    }

    static func buildTermsAndConditionsURL() -> URL? {
        return LetgoURLHelper.composeLocalizedURL(Constants.websiteTermsEndpoint)
    }

    static func buildPrivacyURL() -> URL? {
        return LetgoURLHelper.composeLocalizedURL(Constants.websitePrivacyEndpoint)
    }

    static func buildContactUsURL(user: MyUser?, installation: Installation?, type: ContactUsType = .standard) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(Constants.websiteContactUsEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(user, installation: installation,
                                                                                  type: type)
        return urlComponents.url
    }

    static func buildContactUsURL(userEmail email: String?, installation: Installation?, type: ContactUsType = .standard) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(Constants.websiteContactUsEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(nil, userName: nil, email: email,
                                                                                  installationId: installation?.objectId,
                                                                                  type: type)
        return urlComponents.url
    }


    // MARK: - Private methods

    private static func composeLocalizedURL(_ endpoint: String?) -> URL? {
        let prefLanguage = systemLanguage()

        var language = LetgoURLHelper.defaultLang
        var country = LetgoURLHelper.defaultCountry
        if let preferredCountry = LetgoURLHelper.langsCountryDict[prefLanguage] {
            language = prefLanguage
            country = preferredCountry
        }
        let urlString = environment.localizedWebsiteUrl(country, language: language, endpoint: endpoint)
        return URL(string: urlString)
    }

    private static func systemLanguage() -> String {
        let preferredLanguages = Locale.preferredLanguages
        guard !preferredLanguages.isEmpty else { return LetgoURLHelper.defaultLang }

        for preferredLanguage in preferredLanguages {
            // In case it's like es-ES, just take the first "es"
            let components = preferredLanguage.components(separatedBy: "-")
            guard let lang = components.first else { continue }
            guard let _ = langsCountryDict[lang] else { continue }
            return lang.lowercased()
        }
        return LetgoURLHelper.defaultLang
    }

    private static func buildContactParameters(_ user: MyUser?, installation: Installation?, type: ContactUsType) -> String? {
        return buildContactParameters(user?.objectId, userName: user?.name, email: user?.email,
                                      installationId: installation?.objectId, type: type)
    }
    
    private static func buildContactParameters(_ userId: String?, userName: String?, email: String?, installationId: String?
        , type: ContactUsType) -> String? {
        var param: [String: String] = [:]
        param["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        param["os_version"] = UIDevice.current.systemVersion
        param["device_model"] = DeviceUtil.hardwareDescription()
        param["user_id"] = userId
        param["user_name"] = userName
        param["user_email"] = email
        param["installation_id"] = installationId
        switch type {
        case .standard:
            break
        case .scammer:
            param["moderation"] = "true"
        case .deviceNotAllowed:
            // param["moderation"] = "true"
            //TODO: IMPLEMENT
            break
        }
        return param.map{"\($0)=\($1)"}
            .joined(separator: "&")
            .encodeString()
    }

    private static func buildRecaptchParameters(_ transparent: Bool) -> String {
        let value = transparent ? "true": "false"
        return "transparent=\(value)"
    }
}
