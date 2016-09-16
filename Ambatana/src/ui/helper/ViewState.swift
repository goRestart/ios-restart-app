//
//  ViewState.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum ViewState {
    case Loading
    case Data
    case Empty(LGEmptyViewModel)
    case Error(LGEmptyViewModel)
}


// MARK: - Helpers

extension LGEmptyViewModel {

    var hasAction: Bool {
        return buttonTitle != nil && action != nil
    }

    var iconHeight: CGFloat {
        guard let icon = icon else { return 0 }
        return icon.size.height
    }

    public static func respositoryErrorWithRetry(error: RepositoryError, action: (() -> ())?) -> LGEmptyViewModel {
        switch error {
        case .Network:
            return LGEmptyViewModel.networkErrorWithRetry(action)
        case .Internal, .Forbidden, .Unauthorized, .NotFound, .TooManyRequests, .UserNotVerified, .Conflict,
             .UnprocessableEntity, .InternalServerError, .NotModified, .Other:
            return LGEmptyViewModel.genericErrorWithRetry(action)
        }
    }
}
