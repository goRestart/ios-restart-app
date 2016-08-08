//
//  UILabel+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension UILabel {
    public var rx_optionalText: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { label, text in
            label.text = text
        }.asObserver()
    }
}
