//
//  TakeWhile.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeWhileSink<ElementType, O: ObserverType>
    : Sink<O>
    , ObserverType where O.E == ElementType {
    typealias Parent = TakeWhile<ElementType>
    typealias Element = ElementType

    private let _parent: Parent

    private var _running = true

    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            if !_running {
                return
            }
            
            do {
                _running = try _parent._predicate(value)
            } catch let e {
                forwardOn(.error(e))
                dispose()
                return
            }
            
            if _running {
                forwardOn(.next(value))
            } else {
                forwardOn(.completed)
                dispose()
            }
        case .error, .completed:
            forwardOn(event)
            dispose()
        }
    }
    
}

class TakeWhileSinkWithIndex<ElementType, O: ObserverType>
    : Sink<O>
    , ObserverType where O.E == ElementType {
    typealias Parent = TakeWhile<ElementType>
    typealias Element = ElementType
    
    private let _parent: Parent
    
    private var _running = true
    private var _index = 0
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            if !_running {
                return
            }
            
            do {
                _running = try _parent._predicateWithIndex(value, _index)
                let _ = try incrementChecked(&_index)
            } catch let e {
                forwardOn(.error(e))
                dispose()
                return
            }
            
            if _running {
                forwardOn(.next(value))
            } else {
                forwardOn(.completed)
                dispose()
            }
        case .error, .completed:
            forwardOn(event)
            dispose()
        }
    }
    
}

class TakeWhile<Element>: Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    typealias PredicateWithIndex = (Element, Int) throws -> Bool

    private let _source: Observable<Element>
    private let _predicate: Predicate!
    private let _predicateWithIndex: PredicateWithIndex!

    init(source: Observable<Element>, predicate: @escaping Predicate) {
        _source = source
        _predicate = predicate
        _predicateWithIndex = nil
    }
    
    init(source: Observable<Element>, predicate: @escaping PredicateWithIndex) {
        _source = source
        _predicate = nil
        _predicateWithIndex = predicate
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        if let _ = _predicate {
            let sink = TakeWhileSink(parent: self, observer: observer, cancel: cancel)
            let subscription = _source.subscribe(sink)
            return (sink: sink, subscription: subscription)
        } else {
            let sink = TakeWhileSinkWithIndex(parent: self, observer: observer, cancel: cancel)
            let subscription = _source.subscribe(sink)
            return (sink: sink, subscription: subscription)
        }
    }
}
