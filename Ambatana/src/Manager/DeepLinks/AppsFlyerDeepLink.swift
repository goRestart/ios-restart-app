//
//  AppsFlyerDeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 14/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct AppsFlyerDeepLink {

    let deepLink: DeepLink

    static func buildFromUserActivity(_ userActivity: NSUserActivity) -> AppsFlyerDeepLink? {
        guard let url = userActivity.webpageURL else { return nil }
        return AppsFlyerDeepLink.buildFromUrl(url)
    }

    /**
     Initializer using Appsflyer urls https://letgo.onelink.me/...

     */
    private static func buildFromUrl(_ url: URL) -> AppsFlyerDeepLink? {

        guard let host = url.host, host == "letgo.onelink.me" else {
            //Any nil object or host different than letgo.onelink.me will be treated as error
            return nil
        }
        let params = url.queryParameters
        guard let urlSchemeString = params["af_dp"] else { return nil }
        guard let schemeUrl = URL(string: urlSchemeString) else { return nil }
        guard let uriScheme = UriScheme.buildFromUrl(schemeUrl) else { return nil }
        return AppsFlyerDeepLink(deepLink: uriScheme.deepLink)
    }
}

