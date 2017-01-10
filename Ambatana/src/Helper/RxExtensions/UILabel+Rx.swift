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
}
