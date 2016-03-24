//
//  UriScheme.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum UriScheme {

    case Home

    static func buildFromLaunchOptions(launchOptions: [NSObject: AnyObject]) -> UriScheme? {
        guard let url = launchOptions[UIApplicationLaunchOptionsURLKey] as? NSURL else { return nil }
        return UriScheme.buildFromUrl(url)
    }

    static func buildFromUrl(url: NSURL) -> UriScheme?{
        return nil
    }

    var deepLink: DeepLink {
        switch self {
        case .Home:
            return .Home
        }
    }
}
