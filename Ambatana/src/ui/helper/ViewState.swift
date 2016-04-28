//
//  ViewState.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct ViewErrorData {
    var image: UIImage?
    let title: String?
    let body: String?
    let buttonTitle: String?
    let buttonAction: (() -> Void)?

    var hasAction: Bool {
        return buttonTitle != nil && buttonAction != nil
    }

    var imageHeight: CGFloat {
        guard let image = image else { return 0 }
        return image.size.height
    }

    init(image: UIImage? = nil, title: String? = nil, body: String? = nil, buttonTitle: String? = nil,
         buttonAction: (() -> Void)? = nil){
        self.image = image
        self.title = title
        self.body = body
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}

enum ViewState {
    case FirstLoad
    case Data
    case Error(data: ViewErrorData)
}


// MARK: - Helpers

extension ViewErrorData {
    init(repositoryError: RepositoryError, retryAction: (() -> Void)?) {
        let errTitle: String?
        let errBody: String?
        let errButTitle: String?
        let errImage: UIImage?
        switch repositoryError {
        case .Network:
            errImage = UIImage(named: "err_network")
            errTitle = LGLocalizedString.commonErrorTitle
            errBody = LGLocalizedString.commonErrorNetworkBody
            errButTitle = LGLocalizedString.commonErrorRetryButton
        case .Internal, .Forbidden, .Unauthorized, .NotFound:
            errImage = UIImage(named: "err_generic")
            errTitle = LGLocalizedString.commonErrorTitle
            errBody = LGLocalizedString.commonErrorGenericBody
            errButTitle = LGLocalizedString.commonErrorRetryButton
        }
        self.init(image: errImage, title: errTitle, body: errBody, buttonTitle: errButTitle, buttonAction: retryAction)
    }
}
