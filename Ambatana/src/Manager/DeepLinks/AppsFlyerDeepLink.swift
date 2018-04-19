//
//  AppsFlyerDeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 14/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct AppsFlyerDeepLink {

    static let afdpParam = "af_dp"
    let deepLink: DeepLink
    
    
    // MARK: - Interpretation

    static func buildFromUserActivity(_ userActivity: NSUserActivity) -> AppsFlyerDeepLink? {
        guard let url = userActivity.webpageURL else { return nil }
        return AppsFlyerDeepLink.buildFromUrl(url)
    }
    
    static func buildFromAttributionData(_ attributionData: [AnyHashable : Any]) -> DeepLink? {
        guard let deepLink = attributionData[afdpParam] as? String else { return nil }
        guard let deepLinkUrl = URL(string: deepLinkWithScheme(deepLink: deepLink)) else { return nil }
        guard let uriScheme = UriScheme.buildFromUrl(deepLinkUrl) else { return nil }
        return uriScheme.deepLink
    }

    // Initializer using Appsflyer urls https://letgo.onelink.me/...
    static func buildFromUrl(_ url: URL) -> AppsFlyerDeepLink? {
        guard let host = url.host, host == Constants.appsFlyerLinksHost else {
            //Any nil object or host different than letgo.onelink.me will be treated as error
            return nil
        }
        let params = url.queryParameters
        guard let urlSchemeString = params[afdpParam] else { return nil }
        guard let schemeUrl = URL(string: urlSchemeString) else { return nil }
        guard let uriScheme = UriScheme.buildFromUrl(schemeUrl) else { return nil }
        return AppsFlyerDeepLink(deepLink: uriScheme.deepLink)
    }
    
    // MARK: - Helpers
    
    static func percentEncodeForAmpersands(urlString: String) -> String? {
        // AppsFlyer SDK needs '&' to be percent encoded in order to be correctly read after the app is triggered by
        // the deeplink
        let nonAmpersandCharacters = CharacterSet(charactersIn: "&").inverted
        return urlString.addingPercentEncoding(withAllowedCharacters: nonAmpersandCharacters)
    }
    
    static func deepLinkWithScheme(deepLink: String) -> String {
        guard deepLink.range(of: Constants.deepLinkScheme) == nil else { return deepLink }
        return "\(Constants.deepLinkScheme)\(deepLink)"
    }
}

