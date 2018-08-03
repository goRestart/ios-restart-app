enum NotificationSettingsMailerRouter: URLRequestAuthenticable {
    
    static let notificationSettingsMailerBaseUrl = "/mailer/notification-setting"
    private enum Endpoint: CustomStringConvertible {
        case enable
        case disable
        
        var description: String {
            switch self {
            case .enable:
                return "/enable"
            case .disable:
                return "/disable"
            }
        }
    }
    
    case index
    case enable(groupId: String, settingId: String)
    case disable(groupId: String, settingId: String)
    
    var endpoint: String {
        switch self {
        case .index:
            return "\(NotificationSettingsMailerRouter.notificationSettingsMailerBaseUrl)"
        case let .enable(groupId, settingId):
            return "\(NotificationSettingsMailerRouter.notificationSettingsMailerBaseUrl)/\(groupId)/\(settingId)\(NotificationSettingsMailerRouter.Endpoint.enable)"
        case let .disable(groupId, settingId):
            return "\(NotificationSettingsMailerRouter.notificationSettingsMailerBaseUrl)/\(groupId)/\(settingId)\(NotificationSettingsMailerRouter.Endpoint.disable)"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        return .user
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .index:
            return try Router<NotificationSettingsMailerBaseURL>.index(endpoint: endpoint,
                                                                       params: [:]).asURLRequest()
        case .enable, .disable:
            return try Router<NotificationSettingsMailerBaseURL>.update(endpoint: endpoint,
                                                                        objectId: nil,
                                                                        params: [:],
                                                                        encoding: nil).asURLRequest()
            
        }
    }
}
