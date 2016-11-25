//
//  PostAfterDeleteViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class PostAfterDeleteViewModel: BaseViewModel {

    var title: String {
        return LGLocalizedString.productDeletePostTitle
    }

    var subTitle: String {
        return LGLocalizedString.productDeletePostSubtitle
    }

    var icon: UIImage? {
        return UIImage(named: "ic_delete_sad_face")
    }

    var buttonTitle: String {
        return LGLocalizedString.productDeletePostButtonTitle
    }

    var mainButtonAction: (() -> Void)?

    init(action: (() -> Void)?) {
        self.mainButtonAction = action
        super.init()
    }
}
