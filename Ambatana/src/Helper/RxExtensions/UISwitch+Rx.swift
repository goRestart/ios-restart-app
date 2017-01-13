//
//  UISwitch+Rx.swift
//  LetGo
//
//  Created by Eli Kohen on 30/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UISwitch {
    func value(animated: Bool) -> UIBindingObserver<Base, Bool> {
        return UIBindingObserver<Base, Bool>(UIElement: self.base) { (uiSwitch, value) -> () in
            uiSwitch.setOn(value, animated: animated)
        }
    }
}
