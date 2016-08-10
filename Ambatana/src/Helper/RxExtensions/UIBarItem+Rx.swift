//
//  UIBarItem+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension UIBarItem {
    public var rx_title: AnyObserver<String> {
        return UIBindingObserver(UIElement: self) { barItem, title in
            barItem.title = title
        }.asObserver()
    }

    public var rx_optionalTitle: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { barItem, title in
            barItem.title = title
        }.asObserver()
    }
}
