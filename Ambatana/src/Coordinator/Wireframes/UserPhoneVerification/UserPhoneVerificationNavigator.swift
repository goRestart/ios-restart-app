import LGCoreKit

protocol UserPhoneVerificationNavigator {
    func openCountrySelector(withDelegate: UserPhoneVerificationCountryPickerDelegate)
    func closeCountrySelector()
    func openCodeInput(sentTo phoneNumber: String, with callingCode: String, editing: Bool)
    func closePhoneVerificaction()
}
