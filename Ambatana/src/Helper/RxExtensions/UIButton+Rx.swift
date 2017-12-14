//
//  UIButton+Rx.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

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
