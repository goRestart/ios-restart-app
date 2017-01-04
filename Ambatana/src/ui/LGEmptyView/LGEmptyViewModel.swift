//
//  LGEmptyViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public struct LGEmptyViewModel {
    var icon: UIImage?
    let title: String?
    let body: String?
    let buttonTitle: String?
    let action: (() -> ())?
    var secondaryButtonTitle: String?
    var secondaryAction: (() -> ())?

    public static func networkErrorWithRetry(_ action: (() -> ())?) -> LGEmptyViewModel {
        let icon = UIImage(named: "err_network")
        let title = LGLocalizedString.commonErrorTitle
        let body = LGLocalizedString.commonErrorNetworkBody
        let buttonTitle = LGLocalizedString.commonErrorRetryButton
        return LGEmptyViewModel(icon: icon, title: title, body: body, buttonTitle: buttonTitle, action: action,
            secondaryButtonTitle: nil, secondaryAction: nil)
    }

    public static func genericErrorWithRetry(_ action: (() -> ())?) -> LGEmptyViewModel {
        let icon = UIImage(named: "err_generic")
        let title = LGLocalizedString.commonErrorTitle
        let body = LGLocalizedString.commonErrorGenericBody
        let buttonTitle = LGLocalizedString.commonErrorRetryButton
        return LGEmptyViewModel(icon: icon, title: title, body: body, buttonTitle: buttonTitle, action: action,
            secondaryButtonTitle: nil, secondaryAction: nil)
    }
}
