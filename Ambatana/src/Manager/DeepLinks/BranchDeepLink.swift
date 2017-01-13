//
//  BranchDeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Branch

extension BranchUniversalObject {
    func deepLinkWithProperties(_ properties: BranchLinkProperties?) -> DeepLink? {
        guard let controlParams = properties?.controlParams else { return nil }
        guard let deepLinkPath = controlParams["$deeplink_path"] as? String else { return nil }
        guard let deepLinkUrl = URL(string: "letgo://"+deepLinkPath) else { return nil }
        guard let uriScheme = UriScheme.buildFromUrl(deepLinkUrl) else { return nil }
        return uriScheme.deepLink
    }
}
