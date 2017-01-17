//
//  GlobalFunctions.swift
//  LGCoreKit
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

// Equatable for optional arrays
// Ref: http://stackoverflow.com/questions/29478665/comparing-optional-arrays
func ==<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs,rhs) {
    case (.some(let lhs), .some(let rhs)):
        return lhs == rhs
    case (.none, .none):
        return true
    default:
        return false
    }
}

// Comparable enums
// Ref: http://stackoverflow.com/questions/27869397/swift-enumeration-order-and-comparison
public func < <T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue < b.rawValue
}

public func <= <T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue <= b.rawValue
}

public func > <T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue > b.rawValue
}

public func >= <T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue >= b.rawValue
}

// Synchronizes a asynch closure
// Ref: https://forums.developer.apple.com/thread/11519
public func synchronize<ResultType>(_ asynchClosure: (_ completion: @escaping (ResultType) -> ()) -> Void,
                        timeout: DispatchTime = DispatchTime.distantFuture, timeoutWith: @autoclosure @escaping () -> ResultType) -> ResultType {
    let sem = DispatchSemaphore(value: 0)

    var result: ResultType?

    asynchClosure { (r: ResultType) -> () in
        result = r
        sem.signal()
    }
    _ = sem.wait(timeout: timeout)
    if result == nil {
        result = timeoutWith()
    }
    return result!
}
