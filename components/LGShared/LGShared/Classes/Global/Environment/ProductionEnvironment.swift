
final class ProductionEnvironment: AppEnvironment {
    
    static let amplitudeKey = "6d37fbd6c25243c57676e6d4ce7948bf"
    
    // General
    let appleAppId = "986339882"
    let facebookAppId = "699538486794082"
    let appleMerchantId = "merchant.com.letgo.ios.payments"
    
    // AppsFlyer
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    let appsFlyerAppInviteOneLinkID = "O2PG"

    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"

    // Config
    let configFileName = "ios-prod"
    let configURL = "https://static.letgo.com/mobile-config/ios.json"
    
    // Leanplum
    let leanplumAppId = "app_gYgnjLc98J3vIVHbmdD9W0Qwvy0A3KHMdo4PKd0zJD4"
    let leanplumEnvKey = "prod_OQEDqHOM3iZxZSKbcMuhnMZcee4PKDji5yJGfS5jn64"

    // Website
    let websiteBaseUrl = "https://www.letgo.com"
    let websiteBaseUrlWithLocaleParams = "https://%@.letgo.com/%@"
    
    // Google Ads
    let adTestModeActive = false
    let moreInfoAdUnitIdDFP = "/21636273254/turkey/iOS/moreinfo/320x100"
    let moreInfoAdUnitIdDFPUSA = "/21666124832/us/iOS/moreinfo/320x100"

    let feedAdUnitIdDFPUSA10Ratio = "/21666124832/us/iOS/feed/fluid_var_a"
    let feedAdUnitIdDFPUSA15Ratio = "/21666124832/us/iOS/feed/fluid_var_b"
    let feedAdUnitIdDFPUSA20Ratio = "/21666124832/us/iOS/feed/fluid_var_c"
    
    let feedAdUnitIdAdxUSAForOldUsers = "/21666124832/us/iOS/feed/c_render_var_b"
    let feedAdUnitIdAdxTRForOldUsers = "/21636273254/turkey/iOS/feed/c_render_var_b"
    
    var feedAdUnitIdAdxInstallAppUSA = "/21666124832/us/iOS/feed/c_render_var_a"
    var feedAdUnitIdAdxInstallAppTR = "/21636273254/turkey/iOS/feed/c_render_var_a"
    
    let fullScreenAdUnitIdAdxForAllUsersForUS = "/21666124832/us/iOS/interstitials/inter_var_a"
    let fullScreenAdUnitIdAdxForOldUsersForUS = "/21666124832/us/iOS/interstitials/inter_var_b"

    let moreInfoMultiAdUnitIdDFP = "/21636273254/turkey/iOS/moreinfo/300x250_var_a"
    let moreInfoMultiAdUnitIdDFPUSA = "/21666124832/us/iOS/moreinfo/300x250_var_a"

    let chatSectionAdUnitForOldUsersUS = "/21666124832/us/iOS/chat/300x250_var_b"
    let chatSectionAdUnitForOldUsersTR = "/21636273254/turkey/iOS/chat/300x250_var_b"

    // Stripe
    let stripeAPIKey = "pk_live_t2XkxF05GAxpGgMaxiW45vSs"

    private let _godmode: Bool
    
    required init(godmode: Bool) {
        self._godmode = godmode
    }
    
    var godmode: Bool {
        return _godmode
    }
}
