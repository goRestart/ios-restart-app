import LGComponents

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
                return R.Asset.IconsButtons.icEmailActiveDark.image
            } else {
                return R.Asset.IconsButtons.icEmailDark.image
            }
        case .light:
            if highlighted {
                return R.Asset.IconsButtons.icEmailActive.image
            } else {
                return R.Asset.IconsButtons.icEmail.image
            }
        }
    }

    func passwordIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return R.Asset.IconsButtons.icPasswordActiveDark.image
            } else {
                return R.Asset.IconsButtons.icPasswordDark.image
            }
        case .light:
            if highlighted {
                return R.Asset.IconsButtons.icPasswordActive.image
            } else {
                return R.Asset.IconsButtons.icPassword.image
            }
        }
    }

    func showPasswordIcon(highlighted: Bool) -> UIImage? {
        if highlighted {
            return R.Asset.IconsButtons.icShowPassword.image
        } else {
            return R.Asset.IconsButtons.icShowPasswordInactive.image
        }
    }

    func usernameIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return R.Asset.IconsButtons.icNameActiveDark.image
            } else {
                return R.Asset.IconsButtons.icNameDark.image
            }
        case .light:
            if highlighted {
                return R.Asset.IconsButtons.icNameActive.image
            } else {
                return R.Asset.IconsButtons.icName.image
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
