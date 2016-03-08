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

extension LGCollapsibleLabel {
    public var rx_mainText: AnyObserver<String> {
        return UIBindingObserver(UIElement: self) { label, mainText in
            label.mainText = mainText
            label.setNeedsLayout()
        }.asObserver()
    }
    public var rx_optionalMainText: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { label, mainText in
            label.mainText = mainText ?? ""
            label.setNeedsLayout()
        }.asObserver()
    }
}
