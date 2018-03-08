//
//  BlockingPostingHeaderStep.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 08/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

enum BlockingPostingHeaderStep: Int {
    case takePicture = 1
    case confirmPicture = 2
    case addPrice = 3
    
    var title: String {
        switch self {
        case .takePicture:
            return LGLocalizedString.postHeaderStepTakePicture
        case .confirmPicture:
            return LGLocalizedString.postHeaderStepConfirmPicture
        case .addPrice:
            return LGLocalizedString.postHeaderStepAddPrice
        }
    }
}
