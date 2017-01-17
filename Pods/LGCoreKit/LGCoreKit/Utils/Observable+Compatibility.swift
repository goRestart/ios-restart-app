//
//  Observable+Compatibility.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 29/12/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import RxSwift

public extension ObservableType {
    public func subscribeNext(onNext: ((Self.E) -> Void)?) -> Disposable {
        return subscribe(onNext: onNext)
    }
}
