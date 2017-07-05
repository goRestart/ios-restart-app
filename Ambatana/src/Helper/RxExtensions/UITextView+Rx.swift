//
//  UITextView+Rx.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 05/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UITextView {
    var placeholder: UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (placeholder, text) -> () in
            placeholder.text = text
        }
    }
}
