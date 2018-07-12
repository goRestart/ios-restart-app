//
//  LGEmptyViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct LGEmptyViewModel {
    var icon: UIImage?
    let title: String?
    let body: String?
    let buttonTitle: String?
    let action: (() -> ())?
    let secondaryButtonTitle: String?
    let secondaryAction: (() -> ())?
    let emptyReason: EventParameterEmptyReason?
    let errorCode: Int?
    let errorDescription: String?
    let errorRequestHost: String?
}
