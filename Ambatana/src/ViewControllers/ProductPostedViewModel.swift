//
//  ProductPostedViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductPostedViewModel: BaseViewModel {

    var mainButtonText: String?
    var mainText: String?
    var secondaryText: String?
    var shareInfo: SocialMessage?

    init(postResult: ProductSaveServiceResult) {
        super.init()

        setup(postResult)
    }


    // MARK: - Public methods

    func closeActionPressed() {
        
    }

    func mainActionPressed() {
        //TODO: LAUNCH POST AGAIN!
    }


    // MARK: - Private methods

    private func setup(postResult: ProductSaveServiceResult) {
        if let product = postResult.value {
            mainText = LGLocalizedString.productPostConfirmationTitle
            secondaryText = LGLocalizedString.productPostConfirmationSubtitle
            mainButtonText = LGLocalizedString.productPostConfirmationAnotherButton
            shareInfo = SocialHelper.socialMessageWithTitle(LGLocalizedString.sellShareFbContent, product: product)
        }
        else {
            let error = postResult.error ?? .Internal
            let errorString: String
            switch error {
            case .Network:
                errorString = LGLocalizedString.productPostNetworkError
            default:
                errorString = LGLocalizedString.productPostGenericError
            }
            mainText = LGLocalizedString.commonErrorTitle.capitalizedString
            secondaryText = errorString
            mainButtonText = LGLocalizedString.productPostRetryButton
        }
    }

}