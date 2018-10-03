
public protocol AppEnvironment: AnalyticsAPIKeys {
    
    init(godmode: Bool)
    
    // General
    var godmode: Bool { get }
    var appleAppId: String { get }
    var facebookAppId: String { get }
    var appleMerchantId: String { get }

    // Google login
    var googleServerClientID: String { get }
    var googleClientID: String { get }

    // Config
    var configFileName: String { get }
    var configURL: String { get }

    // Website
    var websiteBaseUrl: String { get }
    var websiteBaseUrlWithLocaleParams: String { get }

    // Google Ads
    var adTestModeActive: Bool { get }
    var moreInfoAdUnitIdDFP: String { get }
    var moreInfoAdUnitIdDFPUSA: String { get }
    var feedAdUnitIdDFPUSA10Ratio: String { get }
    var feedAdUnitIdDFPUSA15Ratio: String { get }
    var feedAdUnitIdDFPUSA20Ratio: String { get }
    var feedAdUnitIdAdxUSAForOldUsers: String { get }
    var feedAdUnitIdAdxTRForOldUsers: String { get }
    var fullScreenAdUnitIdAdxForAllUsersForUS: String { get }
    var fullScreenAdUnitIdAdxForOldUsersForUS: String { get }
    var feedAdUnitIdAdxInstallAppUSA: String { get }
    var feedAdUnitIdAdxInstallAppTR: String { get }
    var moreInfoMultiAdUnitIdDFP: String { get }
    var moreInfoMultiAdUnitIdDFPUSA: String { get }
    var chatSectionAdUnitForOldUsersUS: String { get }
    var chatSectionAdUnitForOldUsersTR: String { get }
    var sectionedFeedAdUnitForUS: String { get }

    // Polymorph
    var feedAdUnitIdPolymorphUSA: String { get }
    var polymorphAdUnit: String { get }

    // Stripe
    var stripeAPIKey: String { get }
}


extension AppEnvironment {
    
    public var amplitudeAPIKey: String {
        // Why this default implementation: https://ambatana.atlassian.net/browse/ABIOS-2510
        if godmode {
            return DevelopmentEnvironment.amplitudeKey
        } else {
            return ProductionEnvironment.amplitudeKey
        }
    }

    public var appsFlyerAppleAppId: String {
        return appleAppId
    }

    public var leanplumAppId: String {
        return appleAppId
    }

    public func websiteUrl(_ endpoint: String) -> String {
        return String(format: "\(websiteBaseUrl)\(endpoint)", arguments: [endpoint])
    }

    public func localizedWebsiteUrl(country: String, language: String, endpoint: String? = nil) -> String {
        let format: String
        if let endpoint = endpoint {
            format = "\(websiteBaseUrlWithLocaleParams)\(endpoint)"
        } else {
            format = "\(websiteBaseUrlWithLocaleParams)"
        }
        return String(format: format, arguments: [country, language])
    }
}
