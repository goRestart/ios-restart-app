import Foundation

public enum UserVerificationRequestStatus: String {
    case completed
    case requested
}

public protocol UserVerificationRequest {
    var requesterUserId: String { get }
    var requestedUserId: String { get }
    var status: UserVerificationRequestStatus { get }
}
