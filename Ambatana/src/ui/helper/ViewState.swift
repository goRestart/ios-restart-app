//
//  ViewState.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

struct ViewErrorData {
    let image: UIImage?
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
