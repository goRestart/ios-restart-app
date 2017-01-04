//
//  ViewState.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum ViewState {
    case loading
    case data
    case empty(LGEmptyViewModel)
    case error(LGEmptyViewModel)
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

    static func respositoryErrorWithRetry(_ error: RepositoryError, action: (() -> ())?) -> LGEmptyViewModel? {
        switch error {
        case let .Network(_, onBackground):
            return onBackground ? nil : LGEmptyViewModel.networkErrorWithRetry(action)
        case .Internal, .Forbidden, .Unauthorized, .NotFound, .TooManyRequests, .UserNotVerified, .ServerError:
            return LGEmptyViewModel.genericErrorWithRetry(action)
        }
    }
}
