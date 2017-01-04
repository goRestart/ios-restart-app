//
//  UISwitch+Rx.swift
//  LetGo
//
//  Created by Eli Kohen on 30/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import RxCocoa

extension UISwitch {
    var rx_valueAnimated: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { uiSwitch, value in
            uiSwitch.setOn(value, animated: true)
        }.asObserver()
    }
}
