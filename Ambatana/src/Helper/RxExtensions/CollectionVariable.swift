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

enum CollectionChange<T> {
    case remove(Int, T)
    case insert(Int, T)
    case composite([CollectionChange])
    
    func index() -> Int? {
        switch self {
        case .remove(let index, _): return index
        case .insert(let index, _): return index
        default: return nil
        }
    }
    
    func element() -> T? {
        switch self {
        case .remove(_, let element): return element
        case .insert(_, let element): return element
        default: return nil
        }
    }
}


final class CollectionVariable<T> {
    
    // MARK: - Attributes
    
    fileprivate let _changesSubject: PublishSubject<CollectionChange<T>>
    fileprivate let _subject: PublishSubject<[T]>
    fileprivate var _lock = NSRecursiveLock()
    var observable: Observable<[T]> { return _subject.asObservable() }
    var changesObservable: Observable<CollectionChange<T>> { return _changesSubject.asObservable() }
    fileprivate var _value: [T]
    var value: [T] {
        get {
            return _value
        }
        set {
            _value = newValue
            _subject.onNext(newValue)
            _changesSubject.onNext(.composite(newValue.mapWithIndex{CollectionChange.insert($0, $1)}))
        }
    }

    
    // MARK: - Init
    
    init(_ value: [T]) {
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

    func bindTo(_ another: CollectionVariable<T>) -> Disposable {
        another.removeAll()
        another.appendContentsOf(self.value)
        return changesObservable.bindNext { [weak another] change in
            another?.handleChange(change: change)
        }
    }
    
    func removeFirst() {
        if (_value.count == 0) { return }
        _lock.lock()
        let deletedElement = _value.removeFirst()
        _changesSubject.onNext(.remove(0, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    func removeLast() {
        _lock.lock()
        if (_value.count == 0) { return }
        let index = _value.count - 1
        let deletedElement = _value.removeLast()
        _changesSubject.onNext(.remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    func removeAll() {
        _lock.lock()
        let copiedValue = _value
        _value.removeAll()
        _changesSubject.onNext(.composite(copiedValue.mapWithIndex{CollectionChange.remove($0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    func removeAtIndex(_ index: Int) {
        _lock.lock()
        let deletedElement = _value.remove(at: index)
        _changesSubject.onNext(CollectionChange.remove(index, deletedElement))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    func append(_ element: T) {
        _lock.lock()
        _value.append(element)
        _changesSubject.onNext(.insert(_value.count - 1, element))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    func appendContentsOf(_ elements: [T]) {
        _lock.lock()
        let count = _value.count
        _value.append(contentsOf: elements)
        _changesSubject.onNext(.composite(elements.mapWithIndex{CollectionChange.insert(count + $0, $1)}))
        _subject.onNext(_value)
        _lock.unlock()
    }
    
    func insert(_ newElement: T, atIndex index: Int) {
        _lock.lock()
        _value.insert(newElement, at: index)
        _changesSubject.onNext(.insert(index, newElement))
        _subject.onNext(_value)
        _lock.unlock()
    }

    func replace(_ index: Int, with element: T) {
        guard 0..<value.count ~= index else { return }
        replace(index..<(index+1), with: [element])
    }

    func replace(_ subRange: CountableRange<Int>, with elements: [T]) {
        _lock.lock()
        precondition(subRange.lowerBound + subRange.count <= _value.count, "Range out of bounds")
        
        var compositeChanges: [CollectionChange<T>] = []
        
        for (index, element) in elements.enumerated() {
            let replacedElement = _value[subRange.lowerBound+index]
            let range = subRange.lowerBound+index..<subRange.lowerBound+index+1
            _value.replaceSubrange(range, with: [element])
            compositeChanges.append(.remove(subRange.lowerBound + index, replacedElement))
            compositeChanges.append(.insert(subRange.lowerBound + index, element))
        }
        _changesSubject.onNext(.composite(compositeChanges))
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
        case let .composite(changes):
            for change in changes {
                handleChange(change: change)
            }
        }
    }
}

extension Array {
    
    func mapWithIndex<T>(_ transform: (Int, Element) -> T) -> [T] {
        var newValues: [T] = []
        for (index, element) in self.enumerated() {
            newValues.append(transform(index, element))
        }
        return newValues
    }
    
}
