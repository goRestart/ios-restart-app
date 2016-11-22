//
//  Observable+IgnoreNil.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 21/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//  Original source: https://gist.github.com/alskipp/e71f014c8f8a9aa12b8d8f8053b67d72
//

import RxSwift

public protocol OptionalType {
    associatedtype Wrapped

    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}

public extension Observable where Element: OptionalType {
    /*
     Acts as a filter for nil values
     */
    func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.empty()
        }
    }
}
