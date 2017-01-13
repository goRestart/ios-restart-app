//
//  UIBarItem+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift


extension Reactive where Base: UIBarItem {
    var title: UIBindingObserver<Base, String> {
        return UIBindingObserver<Base, String>(UIElement: self.base) { (barItem, title) -> () in
            barItem.title = title
        }
    }

    var optionalTitle: UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (barItem, title) -> () in
            barItem.title = title
        }
    }
}
