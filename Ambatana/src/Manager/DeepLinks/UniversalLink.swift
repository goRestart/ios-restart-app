//
//  UniversalLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum UniversalLink {

    case Home

    static func buildFromUserActivity(userActivity: NSUserActivity) -> UniversalLink? {
        guard let url = userActivity.webpageURL else { return nil }
        return UniversalLink.buildFromUrl(url)
    }

    private static func buildFromUrl(url: NSURL) -> UniversalLink? {
        return nil
    }

    var deepLink: DeepLink {
        switch self {
        case .Home:
            return .Home
        }
    }
}
