//
//  LGTimer.swift
//  LetGo
//
//  Created by Facundo Menzella on 25/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol Cancellable {
    func cancel()
}

private final class SwitchVariable: Cancellable {
    let action: Variable<Bool>

    init(withSwitch action: Variable<Bool>) {
        self.action = action
    }

    func cancel() {
        toggle()
    }

    func toggle() {
        action.value = !action.value
    }
}

typealias CancellableWait = (Cancellable, Observable<Any>)

final class LGTimer {
    static func cancellableWait(_ timeout: TimeInterval) -> CancellableWait {
        let variable = Variable<Bool>(false)
        let cancellable = SwitchVariable(withSwitch: variable)

        let timeout = Observable<Any>.never()
                    .timeout(timeout, scheduler: MainScheduler.instance)
                    .takeUntil(variable.asObservable().skip(1).distinct().asObservable())

        return (cancellable, timeout.asObservable())
    }
}
