import LGComponents
import DeviceGuru
import Foundation
import LGCoreKit

enum ContactUsType {
    case standard
    case scammer
    case deviceNotAllowed
    case bumpUpNotAllowed
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

    static func buildProductURL(listingId: String, isLocalized: Bool) -> URL? {
        if isLocalized {
            guard let url = LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteListingEndpoint(listingId)) else { return nil }
            guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            return urlComponents.url
        } else {
            return URL(string: environment.websiteUrl(SharedConstants.websiteListingEndpoint(listingId)))
        }
    }

    static func buildUserURL(userId: String) -> URL? {
        return URL(string: environment.websiteUrl(SharedConstants.websiteUserEndpoint(userId))) // not localized
    }

    static func buildRecaptchaURL() -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteRecaptchaEndpoint) else { return nil }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        return urlComponents.url
    }

    static func buildHelpURL(_ user: MyUser?, installation: Installation?) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteHelpEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(user,
                                                                                  installation: installation,
                                                                                  listing: nil,
                                                                                  type: .standard)
        return urlComponents.url
    }

    static func buildTermsAndConditionsURL() -> URL? {
        return LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteTermsEndpoint)
    }

    static func buildPrivacyURL() -> URL? {
        return LetgoURLHelper.composeLocalizedURL(SharedConstants.websitePrivacyEndpoint)
    }

    static func buildContactUsURL(user: MyUser?, installation: Installation?, listing: Listing?, type: ContactUsType = .standard) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteContactUsEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(user,
                                                                                  installation: installation,
                                                                                  listing: listing,
                                                                                  type: type)
        return urlComponents.url
    }

    static func buildContactUsURL(userEmail email: String?, installation: Installation?, listing: Listing?, type: ContactUsType = .standard) -> URL? {
        guard let url = LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteContactUsEndpoint) else { return nil }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        urlComponents.percentEncodedQuery = LetgoURLHelper.buildContactParameters(nil, userName: nil, email: email,
                                                                                  installationId: installation?.objectId,
                                                                                  listingId: listing?.objectId,
                                                                                  type: type)
        return urlComponents.url
    }

    static func buildCommunityGuidelineURL() -> URL? {
        return LetgoURLHelper.composeLocalizedURL(SharedConstants.websiteCommunityGuideline)
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
        let urlString = environment.localizedWebsiteUrl(country: country,
                                                        language: language,
                                                        endpoint: endpoint)
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

    private static func buildContactParameters(_ user: MyUser?, installation: Installation?, listing: Listing?, type: ContactUsType) -> String? {
        return buildContactParameters(user?.objectId, userName: user?.name, email: user?.email,
                                      installationId: installation?.objectId, listingId: listing?.objectId, type: type)
    }
    
    private static func buildContactParameters(_ userId: String?, userName: String?, email: String?, installationId: String?
        , listingId: String?, type: ContactUsType) -> String? {
        var param: [String: String] = [:]
        param["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        param["os_version"] = UIDevice.current.systemVersion
        param["device_model"] = DeviceGuru().hardwareDescription()
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
            param["device_not_allowed"] = "true"
        case .bumpUpNotAllowed:
            param["bumpup"] = "true"
            param["product_id"] = listingId ?? ""
        }
        return param.map{"\($0)=\($1)"}
            .joined(separator: "&")
            .encodeString()
    }

}
