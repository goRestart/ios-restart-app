import Foundation

enum ReportSentType {
    case productBasic
    case userBasic
    case userBlockA
    case userBlockB
    case userLawEnforcement
    case userLawEnforcementBlock

    var allowsBlockUser: Bool {
        switch self {
            case .userBlockA, .userBlockB, .userLawEnforcementBlock:
            return true
        default:
            return false
        }
    }

    var title: String {
        return "Report Sent!" // FIXME: localize
    }

    var message: String {
        return "Thanks for helping us make ..." // FIXME: define and localize
    }
}
