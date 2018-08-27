
public enum AppEnvironmentType: String {
    case development
    case production
    case escrow
}

public final class EnvironmentProxy: AppEnvironment {
    public static let sharedInstance = EnvironmentProxy(godmode: false)

    public private(set) var environment: AppEnvironment


    // MARK: - Lifecycle

    public required init(godmode: Bool) {
        environment = ProductionEnvironment(godmode: godmode)
    }
    
    // MARK: - Public methods

    public func setEnvironmentType(_ type: AppEnvironmentType, godmode: Bool) {
        switch type {
        case .development:
            environment = DevelopmentEnvironment(godmode: godmode)
        case .production:
            environment = ProductionEnvironment(godmode: godmode)
        case .escrow:
            environment = EscrowEnvironment(godmode: godmode)
        }
    }


    // MARK: - AppEnvironment
    
    public var godmode: Bool {
        return environment.godmode
    }

    public var appleAppId: String {
        return environment.appleAppId
    }

    public var facebookAppId: String {
        return environment.facebookAppId
    }

    public var appleMerchantId: String {
        return environment.appleMerchantId
    }

    public var appsFlyerAPIKey: String {
        return environment.appsFlyerAPIKey
    }
    
    public var appsFlyerAppInviteOneLinkID: String {
        return environment.appsFlyerAppInviteOneLinkID
    }

    public var amplitudeAPIKey: String {
        return environment.amplitudeAPIKey
    }

    public var googleServerClientID: String {
        return environment.googleServerClientID
    }

    public var googleClientID: String {
        return environment.googleClientID
    }

    public var configFileName: String {
        return environment.configFileName
    }

    public var leanplumAppId: String {
        return environment.leanplumAppId
    }

    public var leanplumEnvKey: String {
        return environment.leanplumEnvKey
    }

    public var configURL: String {
        return environment.configURL
    }

    public var websiteBaseUrl: String {
        return environment.websiteBaseUrl
    }

    public var websiteBaseUrlWithLocaleParams: String {
        return environment.websiteBaseUrlWithLocaleParams
    }

    public var adTestModeActive: Bool {
        return environment.adTestModeActive
    }

    public var moreInfoAdUnitIdDFP: String {
        return environment.moreInfoAdUnitIdDFP
    }

    public var moreInfoAdUnitIdDFPUSA: String {
        return environment.moreInfoAdUnitIdDFPUSA
    }

    public var feedAdUnitIdDFPUSA10Ratio: String {
        return environment.feedAdUnitIdDFPUSA10Ratio
    }

    public var feedAdUnitIdDFPUSA15Ratio: String {
        return environment.feedAdUnitIdDFPUSA15Ratio
    }

    public var feedAdUnitIdDFPUSA20Ratio: String {
        return environment.feedAdUnitIdDFPUSA20Ratio
    }
    
    public var feedAdUnitIdAdxUSAForOldUsers: String {
        return environment.feedAdUnitIdAdxUSAForOldUsers
    }
    
    public var feedAdUnitIdAdxTRForOldUsers: String {
        return environment.feedAdUnitIdAdxTRForOldUsers
    }

    public var moreInfoMultiAdUnitIdDFP: String {
        return environment.moreInfoMultiAdUnitIdDFP
    }

    public var moreInfoMultiAdUnitIdDFPUSA: String {
        return environment.moreInfoMultiAdUnitIdDFPUSA
    }

    public var stripeAPIKey: String {
        return environment.stripeAPIKey
    }
    
    public var fullScreenAdUnitIdAdxForAllUsersForUS: String {
        return environment.fullScreenAdUnitIdAdxForAllUsersForUS
    }
    
    public var fullScreenAdUnitIdAdxForOldUsersForUS: String {
        return environment.fullScreenAdUnitIdAdxForOldUsersForUS
    }
    
    public var feedAdUnitIdAdxInstallAppUSA: String {
        return environment.feedAdUnitIdAdxInstallAppUSA
    }
    
    public var feedAdUnitIdAdxInstallAppTR: String {
        return environment.feedAdUnitIdAdxInstallAppTR
    }
    
}
