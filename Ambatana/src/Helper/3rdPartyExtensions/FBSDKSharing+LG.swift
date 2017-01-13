//
//  FBSDKSharingExtension.swift
//  LetGo
//
//  Created by Isaac Roldan on 18/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import FBSDKShareKit

enum FBSDKSharerType {
    case facebook
    case fbMessenger
    case unknown
}

extension FBSDKSharing {
    var type: FBSDKSharerType {
        if self is FBSDKShareDialog {
            return .facebook
        }
        if self is FBSDKMessageDialog {
            return .fbMessenger
        }
        return .unknown
    }
}
