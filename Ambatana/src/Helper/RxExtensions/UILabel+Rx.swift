//
//  UILabel+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UILabel {
    var optionalText: UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (label, text) -> () in
            label.text = text
        }
    }

    var textColor: UIBindingObserver<Base, UIColor> {
        return UIBindingObserver<Base, UIColor>(UIElement: self.base) { (label, color) -> () in
            label.textColor = color
        }
    }
    
    public var isEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { control, value in
            control.isEnabled = value
        }
    }
}
