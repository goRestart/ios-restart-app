//
//  BlockingPostingHeaderStep.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 08/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

enum BlockingPostingHeaderStep {
    case takePicture
    case confirmPicture
    case addPrice
    
    var number: Int {
        switch self {
        case .takePicture:
            return 1
        case .confirmPicture:
            return 2
        case .addPrice:
            return 3
        }
    }
    
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
