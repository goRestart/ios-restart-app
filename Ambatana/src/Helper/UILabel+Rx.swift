//
//  UILabel+Rx.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UILabel {
   
    /// Bindable sink for `isEnabled` property.
    public var isEnabled: Binder<Bool> {
        return Binder(self.base) { label, isEnabled in
            label.isEnabled = isEnabled
        }
    }
}
