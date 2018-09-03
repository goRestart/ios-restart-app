import LGCoreKit

protocol SignUpLogInNavigator: class {
    func cancelSignUpLogIn()
    func closeSignUpLogInSuccessful(with myUser: MyUser)
    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openRecaptcha(action: LoginActionType)

    func openRememberPasswordFromSignUpLogIn(email: String?)
    func openHelpFromSignUpLogin()
    func open(url: URL)
}
