import Foundation

final class PhoneCallsHelper {
    static var deviceCanCall: Bool {
        guard let callUrl = URL(string: "tel:") else { return false }
        return UIApplication.shared.canOpenURL(callUrl)
    }

    static func call(phoneNumber: String) {
        guard let phoneUrl = URL(string: "tel:\(phoneNumber)") else { return }
        UIApplication.shared.openURL(phoneUrl)
    }
}
