import Foundation
import Alamofire

public enum EventParameterRefreshTokenOrigin {
    case api
    case websocket
}

extension EventParameterRefreshTokenOrigin: CustomStringConvertible {
    public var description: String {
        switch self {
        case .api: return "api"
        case .websocket: return "websocket"
        }
    }
}

public enum EventParameterAuthLevel: String {
    case nonexistent = "nonexistent"
    case installation = "installation"
    case user = "user"
}

public protocol CoreTracker: class {
    func trackRefreshTokenResponse(origin: EventParameterRefreshTokenOrigin,
                                   success: Bool,
                                   description: String?)
    func trackRefreshToken(origin: EventParameterRefreshTokenOrigin,
                           originDomain: String?,
                           tokenLevel: EventParameterAuthLevel)
    func trackRequestTimeOut(host: String,
                             endpoint: String,
                             statusCode: Int?,
                             errorCode: Int?,
                             timeline: Timeline)
}
