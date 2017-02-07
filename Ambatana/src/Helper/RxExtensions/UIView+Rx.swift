//
//  UIView+Rx.swift
//  LetGo
//
//  Created by Dídac on 07/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UIView {
    var backgroundColor: UIBindingObserver<Base, UIColor?> {
        return UIBindingObserver<Base, UIColor?>(UIElement: self.base) { (view, color) -> () in
            view.backgroundColor = color
        }
    }
}
