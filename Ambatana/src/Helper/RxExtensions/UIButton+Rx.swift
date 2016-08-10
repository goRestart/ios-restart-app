//
//  UIButton+Rx.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension UIButton {
    public var rx_title: AnyObserver<String> {
        return UIBindingObserver(UIElement: self) { button, text in
            button.setTitle(text, forState: UIControlState.Normal)
        }.asObserver()
    }

    public var rx_optionalTitle: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { button, text in
            button.setTitle(text, forState: UIControlState.Normal)
        }.asObserver()
    }

    public var rx_image: AnyObserver<UIImage?> {
        return UIBindingObserver(UIElement: self) { button, image in
            button.setImage(image, forState: UIControlState.Normal)
        }.asObserver()
    }
}
