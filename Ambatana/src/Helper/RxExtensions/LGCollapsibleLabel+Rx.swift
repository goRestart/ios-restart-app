//
//  LGCollapsibleLabel+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

//import LGCollapsibleLabel //TODO: RE-ENABLE after swift 3 migration
import RxCocoa
import RxSwift

extension LGCollapsibleLabel {
    var rx_mainText: AnyObserver<String> {
        return UIBindingObserver(UIElement: self) { label, mainText in
            label.mainText = mainText
            label.setNeedsLayout()
        }.asObserver()
    }
    var rx_optionalMainText: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { label, mainText in
            label.mainText = mainText ?? ""
            label.setNeedsLayout()
        }.asObserver()
    }
}
