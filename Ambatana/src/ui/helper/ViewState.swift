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

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .data, .empty, .error:
            return false
        }
    }

    var isData: Bool {
        switch self {
        case .data:
            return true
        case .loading, .empty, .error:
            return false
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        case .data, .error, .loading:
            return false
        }
    }
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
        case let .network(_, onBackground):
            return onBackground ? nil : LGEmptyViewModel.networkErrorWithRetry(action)
        case .internalError, .forbidden, .unauthorized, .notFound, .tooManyRequests, .userNotVerified, .serverError:
            return LGEmptyViewModel.genericErrorWithRetry(action)
        }
    }
}
