import LGCoreKit

protocol MainSignUpNavigator: class {
    func cancelMainSignUp()
    func closeMainSignUpSuccessful(with myUser: MyUser)
    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func closeMainSignUpAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openSignUpEmailFromMainSignUp()
    func openLogInEmailFromMainSignUp()

    func openHelpFromMainSignUp()
    func open(url: URL)
}
