//
//  RxTest+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 18/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxTest
import RxSwift
import XCTest

public func == <Element: Equatable>(lhs: Event<Element?>, rhs: Event<Element?>) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case (.error(let e1), .error(let e2)):
        #if os(Linux)
            return  "\(e1)" == "\(e2)"
        #else
            let error1 = e1 as NSError
            let error2 = e2 as NSError

            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(e1)" == "\(e2)"
        #endif
    case (.next(let v1), .next(let v2)): return v1 == v2
    default: return false
    }
}

public func == <T: Equatable>(lhs: Recorded<Event<T?>>, rhs: Recorded<Event<T?>>) -> Bool {
    guard lhs.time == rhs.time else { return false }
    return lhs.value == rhs.value
}

public func XCTAssertEqual<T: Equatable>(_ lhs: [Recorded<Event<T?>>], _ rhs: [Recorded<Event<T?>>], file: StaticString = #file, line: UInt = #line) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    #if os(Linux)
        XCTAssertEqual(leftEquatable, rightEquatable)
    #else
        XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
    #endif

    if leftEquatable == rightEquatable {
        return
    }

    printSequenceDifferences(lhs, rhs, ==)
}




// From here & below are just private elements of RxTest that needed to be copied

struct AnyEquatable<Target>
: Equatable {
    typealias Comparer = (Target, Target) -> Bool

    let _target: Target
    let _comparer: Comparer

    init(target: Target, comparer: @escaping Comparer) {
        _target = target
        _comparer = comparer
    }
}

func == <T>(lhs: AnyEquatable<T>, rhs: AnyEquatable<T>) -> Bool {
    return lhs._comparer(lhs._target, rhs._target)
}

extension AnyEquatable
    : CustomDebugStringConvertible
, CustomStringConvertible  {
    var description: String {
        return "\(_target)"
    }

    var debugDescription: String {
        return "\(_target)"
    }
}

func printSequenceDifferences<E>(_ lhs: [E], _ rhs: [E], _ equal: (E, E) -> Bool) {
    print("Differences:")
    for (index, elements) in zip(lhs, rhs).enumerated() {
        let l = elements.0
        let r = elements.1
        if !equal(l, r) {
            print("lhs[\(index)]:\n    \(l)")
            print("rhs[\(index)]:\n    \(r)")
        }
    }

    let shortest = min(lhs.count, rhs.count)
    for (index, element) in lhs[shortest ..< lhs.count].enumerated() {
        print("lhs[\(index + shortest)]:\n    \(element)")
    }
    for (index, element) in rhs[shortest ..< rhs.count].enumerated() {
        print("rhs[\(index + shortest)]:\n    \(element)")
    }
}

