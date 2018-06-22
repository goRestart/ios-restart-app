enum NotificationSettingsPusherRouter: URLRequestAuthenticable {
    
    static let notificationSettingsPusherBaseUrl = "/pusher/notification-setting"
    private enum Endpoint: String {
        case enable = "/enable"
        case disable = "/disable"
    }
    
    case index
    case enable(groupId: String, settingId: String)
    case disable(groupId: String, settingId: String)
    
    var endpoint: String {
        switch self {
        case .index:
            return "\(NotificationSettingsPusherRouter.notificationSettingsPusherBaseUrl)"
        case let .enable(groupId, settingId):
            return "\(NotificationSettingsPusherRouter.notificationSettingsPusherBaseUrl)/\(groupId)/\(settingId)\(NotificationSettingsPusherRouter.Endpoint.enable.rawValue)"
        case let .disable(groupId, settingId):
            return "\(NotificationSettingsPusherRouter.notificationSettingsPusherBaseUrl)/\(groupId)/\(settingId)\(NotificationSettingsPusherRouter.Endpoint.disable.rawValue)"
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        return .user
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .index:
            return try Router<NotificationSettingsPusherBaseURL>.index(endpoint: endpoint,
                                                                       params: [:]).asURLRequest()
        case .enable, .disable:
            return try Router<NotificationSettingsPusherBaseURL>.update(endpoint: endpoint,
                                                                        objectId: nil,
                                                                        params: [:],
                                                                        encoding: nil).asURLRequest()

        }
    }
}
