import LGCoreKit

extension LGEmptyViewModel {
    
    static func map(from error: RepositoryError, action: (() -> ())?) -> LGEmptyViewModel? {
        guard !isBackground(error) else { return nil }
        let icon = LGEmptyViewModel.icon(for: error)
        let body = LGEmptyViewModel.body(for: error)
        let reason = LGEmptyViewModel.reason(for: error)
        let errorCode = LGEmptyViewModel.errorCode(for: error)
        return LGEmptyViewModel(
            icon: icon,
            title: LGLocalizedString.commonErrorTitle,
            body: body,
            buttonTitle: LGLocalizedString.commonErrorRetryButton,
            action: action,
            secondaryButtonTitle: nil,
            secondaryAction: nil,
            emptyReason: reason,
            errorCode: errorCode)
    }
}

fileprivate extension LGEmptyViewModel {
    
    static func isBackground(_ error: RepositoryError) -> Bool {
        switch error {
        case .network(_, let onBackground):
            return onBackground
        case .wsChatError(let chatError):
            return isBackground(chatError)
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .searchAlertError:
            return false
        }
    }
    
    static func isBackground(_ chatError: ChatRepositoryError) -> Bool {
        switch chatError {
        case .network(_, let onBackground):
            return onBackground
        case .notAuthenticated, .userNotVerified, .userBlocked, .internalError, .apiError, .differentCountry:
            return false
        }
    }
    
    static func icon(for error: RepositoryError) -> UIImage? {
        switch error {
        case .network:
            return UIImage(named: "err_network")
        case .wsChatError(let chatError):
            return icon(for: chatError)
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .searchAlertError:
            return UIImage(named: "err_generic")
        }
    }
    
    static func icon(for chatError: ChatRepositoryError) -> UIImage? {
        switch chatError {
        case .network:
            return UIImage(named: "err_network")
        case .notAuthenticated, .userNotVerified, .userBlocked, .internalError, .apiError, .differentCountry:
            return UIImage(named: "err_generic")
        }
    }
    
    static func body(for error: RepositoryError) -> String {
        switch error {
        case .network:
            return LGLocalizedString.commonErrorNetworkBody
        case .wsChatError(let chatError):
            return body(for: chatError)
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .searchAlertError:
            return LGLocalizedString.commonErrorGenericBody
        }
    }
    
    static func body(for chatError: ChatRepositoryError) -> String {
        switch chatError {
        case .network:
            return LGLocalizedString.commonErrorNetworkBody
        case .notAuthenticated, .userNotVerified, .userBlocked, .internalError, .apiError, .differentCountry:
            return LGLocalizedString.commonErrorGenericBody
        }
    }
    
    static func reason(for error: RepositoryError) -> EventParameterEmptyReason {
        switch error {
        case .network:
            return .noInternetConection
        case .wsChatError(let chatError):
            return reason(for: chatError)
        case .serverError:
            return .serverError
        case .notFound:
            return .notFound
        case .userNotVerified:
            return .userNotVerified
        case .internalError:
            return .internalError
        case .unauthorized:
            return .unauthorized
        case .forbidden:
            return .forbidden
        case .tooManyRequests:
            return .tooManyRequests
        case .searchAlertError:
            return .internalError
        }
    }

    static func reason(for chatError: ChatRepositoryError) -> EventParameterEmptyReason {
        switch chatError {
        case .network:
            return .noInternetConection
        case .apiError:
            return .chatServerError
        case .internalError:
            return .wsInternalError
        case .userNotVerified:
            return .userNotVerified
        case .userBlocked:
            return .chatUserBlocked
        case .notAuthenticated:
            return .notAuthenticated
        case .differentCountry:
            return .differentCountry
        }
    }
    
    static func errorCode(for error: RepositoryError) -> Int? {
        switch error {
        case .network(let errorCode, _):
            return errorCode
        case .wsChatError(let chatError):
            return errorCode(for: chatError)
        case .serverError(let code):
            return code
        case .internalError(let message):
            return Int(message)
        case .unauthorized(_, let description):
            if let description = description {
                return Int(description)
            } else {
                return nil
            }
        case .notFound, .forbidden, .tooManyRequests, .userNotVerified, .searchAlertError:
            return nil
        }
    }
    
    static func errorCode(for chatError: ChatRepositoryError) -> Int? {
        switch chatError {
        case .network(let errorCode, _):
            return errorCode
        case .apiError(let httpCode):
            return httpCode
        case .internalError(let message):
            return Int(message)
        case .notAuthenticated, .userNotVerified, .userBlocked, .differentCountry:
            return nil
        }
    }
}
