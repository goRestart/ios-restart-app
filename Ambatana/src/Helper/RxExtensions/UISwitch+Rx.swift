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
    public var rx_valueAnimated: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { uiSwitch, on in
            uiSwitch.setOn(on, animated: true)
        }.asObserver()
    }
}
