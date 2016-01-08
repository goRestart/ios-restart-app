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
    case Facebook
    case FBMessenger
    case Unknown
}

extension FBSDKSharing {
    var type: FBSDKSharerType {
        if self is FBSDKShareDialog {
            return .Facebook
        }
        if self is FBSDKMessageDialog {
            return .FBMessenger
        }
        return .Unknown
    }
}