import UIKit

extension LoginAppearance {
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .dark:
            return .lightContent
        case .light:
            return .default
        }
    }

    var navBarBackgroundStyle: NavBarBackgroundStyle {
        switch self {
        case .dark:
            return .transparent(substyle: .dark)
        case .light:
            return .transparent(substyle: .light)
        }
    }

    var headerGradientIsHidden: Bool {
        switch self {
        case .dark:
            return true
        case .light:
            return false
        }
    }

    var hasBackgroundImage: Bool {
        switch self {
        case .dark:
            return true
        case .light:
            return false
        }
    }

    var textFieldButtonStyle: ButtonStyle {
        switch self {
        case .dark:
            return .darkField
        case .light:
            return .lightField
        }
    }

    var labelTextColor: UIColor {
        switch self {
        case .dark:
            return UIColor.whiteTextHighAlpha
        case .light:
            return UIColor.blackTextHighAlpha
        }
    }

    var textFieldTextColor: UIColor {
        switch self {
        case .dark:
            return UIColor.whiteText
        case .light:
            return UIColor.blackText
        }
    }

    var textFieldPlaceholderColor: UIColor {
        switch self {
        case .dark:
            return UIColor.whiteTextHighAlpha
        case .light:
            return UIColor.blackTextHighAlpha
        }
    }

    var textViewTintColor: UIColor {
        switch self {
        case .dark:
            return UIColor.white
        case .light:
            return UIColor.primaryColor
        }
    }

    var lineColor: UIColor {
        switch self {
        case .dark:
            return UIColor.lgBlack
        case .light:
            return UIColor.white
        }
    }

    func emailIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return #imageLiteral(resourceName: "ic_email_active_dark")
            } else {
                return #imageLiteral(resourceName: "ic_email_dark")
            }
        case .light:
            if highlighted {
                return #imageLiteral(resourceName: "ic_email_active")
            } else {
                return #imageLiteral(resourceName: "ic_email")
            }
        }
    }

    func passwordIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return #imageLiteral(resourceName: "ic_password_active_dark")
            } else {
                return #imageLiteral(resourceName: "ic_password_dark")
            }
        case .light:
            if highlighted {
                return #imageLiteral(resourceName: "ic_password_active")
            } else {
                return #imageLiteral(resourceName: "ic_password")
            }
        }
    }

    func showPasswordIcon(highlighted: Bool) -> UIImage? {
        if highlighted {
            return #imageLiteral(resourceName: "ic_show_password")
        } else {
            return #imageLiteral(resourceName: "ic_show_password_inactive")
        }
    }

    func usernameIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return #imageLiteral(resourceName: "ic_name_active_dark")
            } else {
                return #imageLiteral(resourceName: "ic_name_dark")
            }
        case .light:
            if highlighted {
                return #imageLiteral(resourceName: "ic_name_active")
            } else {
                return #imageLiteral(resourceName: "ic_name")
            }
        }
    }

    var rememberPasswordTextColor: UIColor {
        return buttonTextColor
    }

    var footerMainTextColor: UIColor {
        return buttonTextColor
    }

    private var buttonTextColor: UIColor {
        switch self {
        case .dark:
            return UIColor.white
        case .light:
            return UIColor.darkGrayText
        }
    }
}
