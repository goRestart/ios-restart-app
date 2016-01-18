//
//  ErrorData.swift
//  LetGo
//
//  Created by Dídac on 12/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


public struct ErrorData {

    var isScammer: Bool
    var errBgColor: UIColor?
    var errBorderColor: UIColor?
    var errImage: UIImage?
    var errTitle: String?
    var errBody: String?
    var errButTitle: String?

    init() {
        self.init(isScammer: false,
            errBgColor: UIColor(patternImage: UIImage(named: "placeholder_pattern")!),
            errBorderColor: StyleHelper.lineColor,
            errImage: UIImage(named: "err_generic"),
            errTitle: LGLocalizedString.commonErrorTitle,
            errBody: LGLocalizedString.commonErrorGenericBody,
            errButTitle: LGLocalizedString.commonErrorRetryButton)
    }

    init(isScammer: Bool, errBgColor: UIColor?, errBorderColor: UIColor?, errImage: UIImage?, errTitle: String?,
        errBody: String?, errButTitle: String?) {
            self.isScammer = isScammer
            self.errBgColor = errBgColor
            self.errBorderColor = errBorderColor
            self.errImage = errImage
            self.errTitle = errTitle
            self.errBody = errBody
            self.errButTitle = errButTitle
    }
}
