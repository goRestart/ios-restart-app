//
//  TourLoginState+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
@testable import LetGoGodMode

extension TourLoginState: Equatable {
    public static func ==(lhs: TourLoginState, rhs: TourLoginState) -> Bool {
        return lhs.loading == rhs.loading && lhs.closeEnabled == rhs.closeEnabled && lhs.emailAsField == rhs.emailAsField
    }

    var loading: Bool {
        switch self {
        case .loading:
            return true
        case .active:
            return false
        }
    }

    var closeEnabled: Bool? {
        switch self {
        case .loading:
            return nil
        case let .active(closeEnabled, _):
            return closeEnabled
        }
    }

    var emailAsField: Bool? {
        switch self {
        case .loading:
            return nil
        case let .active(_, emailAsField):
            return emailAsField
        }
    }
}
