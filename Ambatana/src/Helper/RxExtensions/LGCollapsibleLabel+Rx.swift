//
//  LGCollapsibleLabel+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCollapsibleLabel
import RxCocoa
import RxSwift

extension Reactive where Base: LGCollapsibleLabel {
    var mainText: UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (label, mainText) -> () in
            label.mainText = mainText
            label.setNeedsLayout()
        }
    }
}
