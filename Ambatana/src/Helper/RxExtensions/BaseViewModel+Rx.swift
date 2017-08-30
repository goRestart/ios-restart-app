//
//  BaseViewModel+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 30/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension BaseViewModel: ReactiveCompatible { }

extension Reactive where Base: BaseViewModel {
    var active: UIBindingObserver<Base, Bool> {
        return UIBindingObserver<Base, Bool>(UIElement: self.base) { (view, active) -> () in
            view.active = active
        }
    }
}
