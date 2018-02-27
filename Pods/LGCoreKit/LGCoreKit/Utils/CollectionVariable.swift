//
//  CollectionVariable.swift
//  LetGo
//
//  Created by Eli Kohen on 04/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//
//  Initial version from: https://github.com/pepibumur/CollectionVariable/blob/f508058a19a076729ca41afbdfbaef355d873536/CollectionVariable/CollectionVariable.swift
//


import Foundation
import RxSwift

public enum CollectionChange<T> {
    case remove(Int, T)
    case insert(Int, T)
    case swap(from: Int, to: Int, replacingWith: T?)
    case move(from: Int, to: Int, replacingWith: T?)
    case composite([CollectionChange])
    
    public func index() -> Int? {
        switch self {
        case .remove(let index, _): return index
        case .insert(let index, _): return index
        default: return nil
        }
    }
    
    public func element() -> T? {
        switch self {
        case .remove(_, let element): return element
        case .insert(_, let element): return element
        default: return nil
        }
    }
}

public final class CollectionVariable<T> {
    
    // MARK: - Attributes
    
    fileprivate let _changesSubject: PublishSubject<CollectionChange<T>>
    fileprivate let _subject: PublishSubject<[T]>
    fileprivate var _lock = NSRecursiveLock()
    public var observable: Observable<[T]> { return _subject.asObservable() }
    public var changesObservable: Observable<CollectionChange<T>> { return _changesSubject.asObservable() }
    fileprivate var _value: [T]
    public var value: [T] {
        get {
            return _value
        }
    }
    
    
    // MARK: - Init
    
    public init(_ value: [T]) {
        var initialChanges: [CollectionChange<T>] = []
        for (index, element) in value.enumerated() {
            initialChanges.append(.insert(index, element))
        }
        _value = value
        _changesSubject = PublishSubject()
        _changesSubject.onNext(.composite(initialChanges))
        _subject = PublishSubject()
        _subject.onNext(value)
    }
    
    
    // MARK: - Public
        
    public func removeFirst() {
        if (_value.count == 0) { return }
        _lock.lock()
        let deletedElement = _value.removeFirst()
        _changesSubject.onNext(.remove(0, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeLast() {
        _lock.lock()
        if (_value.count == 0) { return }
        let index = _value.count - 1
        let deletedElement = _value.removeLast()
        _changesSubject.onNext(.remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeAll() {
        _lock.lock()
        let copiedValue = _value
        _value.removeAll()
        _changesSubject.onNext(.composite(copiedValue.mapWithIndex{CollectionChange.remove($0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func removeAtIndex(_ index: Int) {
        _lock.lock()
        let deletedElement = _value.remove(at: index)
        _changesSubject.onNext(CollectionChange.remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func append(_ element: T) {
        _lock.lock()
        _value.append(element)
        _changesSubject.onNext(.insert(_value.count - 1, element))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func appendContentsOf(_ elements: [T]) {
        _lock.lock()
        let count = _value.count
        _value.append(contentsOf: elements)
        _changesSubject.onNext(.composite(elements.mapWithIndex{CollectionChange.insert(count + $0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func insert(_ newElement: T, atIndex index: Int) {
        _lock.lock()
        _value.insert(newElement, at: index)
        _changesSubject.onNext(.insert(index, newElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func replaceAll(with elements: [T]) {
        _lock.lock()
        _value = elements
        _subject.onNext(elements)
        _changesSubject.onNext(.composite(elements.mapWithIndex{CollectionChange.insert($0, $1)}))
        _lock.unlock()
    }

    public func replace(_ index: Int, with element: T) {
        guard 0..<value.count ~= index else { return }
        replace(index..<(index+1), with: [element])
    }
    
    public func replace(_ subRange: CountableRange<Int>, with elements: [T]) {
        _lock.lock()
        let minIndex = subRange.lowerBound
        let removeMaxIndex = subRange.lowerBound + subRange.count
        precondition(minIndex >= 0 && removeMaxIndex <= _value.count, "Range out of bounds")
        
        var compositeChanges: [CollectionChange<T>] = []
        // remove the specified range
        for index in minIndex..<removeMaxIndex {
            let element = _value[index]
            compositeChanges.append(.remove(index, element))
        }
        // insert the new array in that range
        let insertMaxIndex = minIndex + elements.count
        for index in minIndex..<insertMaxIndex {
            let elementsIndex = index - minIndex
            let element = elements[elementsIndex]
            compositeChanges.append(.insert(index, element))
        }
        
        _value.replaceSubrange(subRange, with: elements)
        _changesSubject.onNext(.composite(compositeChanges))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func swap(fromIndex: Int, toIndex: Int, replacingWith element: T? = nil) {
        let range = 0..<_value.count
        precondition(fromIndex != toIndex, "Cannot move to same index")
        precondition(range ~= fromIndex && range ~= toIndex, "Range out of bounds")
        
        _lock.lock()
        // TODO: swift 4 suggested this change, review if it works as expected
        _value.swapAt(fromIndex, toIndex)
        if let replaceElement = element {
            _value[toIndex] = replaceElement
        }
        _changesSubject.onNext(.swap(from: fromIndex, to: toIndex, replacingWith: element))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    public func move(fromIndex: Int, toIndex: Int, replacingWith element: T? = nil) {
        let range = 0..<_value.count
        precondition(range ~= fromIndex && range ~= toIndex, "Range out of bounds")
        
        _lock.lock()
        _value.move(fromIndex: fromIndex, toIndex: toIndex)
        if let element = element {
            _value.replaceSubrange(toIndex..<(toIndex+1), with: [element])
        }
        _changesSubject.onNext(.move(from: fromIndex, to: toIndex, replacingWith: element))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    deinit {
        _subject.onCompleted()
        _changesSubject.onCompleted()
    }
    
    
    // MARK: - Private
    
    private func handleChange(change: CollectionChange<T>) {
        switch change {
        case let .insert(index, value):
            insert(value, atIndex: index)
        case let .remove(index, _):
            removeAtIndex(index)
        case let .swap(fromIndex, toIndex, replacingWith):
            swap(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .move(fromIndex, toIndex, replacingWith):
            move(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .composite(changes):
            for change in changes {
                handleChange(change: change)
            }
        }
    }
}

public extension Array {
    func mapWithIndex<T>(_ transform: (Int, Element) -> T) -> [T] {
        var newValues: [T] = []
        for (index, element) in self.enumerated() {
            newValues.append(transform(index, element))
        }
        return newValues
    }
    
}
