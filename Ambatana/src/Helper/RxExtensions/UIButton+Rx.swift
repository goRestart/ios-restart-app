//
//  UIButton+Rx.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIButton {
    var optionalTitle: UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (button, title) -> () in
            button.setTitle(title, for: UIControlState.normal)
        }
    }

    var image: UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver<Base, UIImage?>(UIElement: self.base) { (button, image) -> () in
            button.setImage(image, for: UIControlState.normal)
        }
    }

    var state: UIBindingObserver<Base, ButtonState> {
        return UIBindingObserver<Base, ButtonState>(UIElement: self.base) { (button, state) -> () in
            button.setState(state)
        }
    }
}


// MARK: - UIButton + VerifyButtonState

extension Reactive where Base: UIButton {
    var verifyState: UIBindingObserver<Base, VerifyButtonState>  {
        return UIBindingObserver<Base, VerifyButtonState>(UIElement: self.base) { (button, state) -> () in
            switch state {
            case .hidden:
                button.isHidden = true
            case .enabled:
                button.isHidden = false
                button.isEnabled = true
            case .disabled, .loading:
                button.isHidden = false
                button.isEnabled = false
            }
        }
    }
}
