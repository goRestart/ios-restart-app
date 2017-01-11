//
//  CollectionVariableSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 04/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
// 
//  Initial version from: https://github.com/pepibumur/CollectionVariable/blob/f508058a19a076729ca41afbdfbaef355d873536/CollectionVariableTests/CollectionVariableTests.swift
//

import XCTest
import Quick
import Nimble
import RxSwift

@testable import LetGo

class CollectionVariableTests: QuickSpec {

    override func spec() {

        describe("initialization") {

            it("should properly update the value once initialized") {
                let array: [String] = ["test1, test2"]
                let property: CollectionVariable<String> = CollectionVariable(array)
                expect(property.value) == array
            }
        }

        describe("updates") {

            context("full update") {

                it("should notify the main observable") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(_):
                                done()
                            default: break
                            }
                        })
                        variable.value = ["test2", "test3"]
                    })
                }

                it("should notify the changes observable with the replaced enum type") {
                    let array: [String] = ["test1", "test2"]
                    let newArray: [String] = ["test2", "test3"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: {
                        (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .composite(let changes):
                                    let indexes = changes.map({$0.index()!})
                                    let elements = changes.map({$0.element()!})
                                    expect(indexes) == [0, 1]
                                    expect(elements) == ["test2", "test3"]
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.value = newArray
                    })
                }
            }

        }

        describe("deletion") {

            context("delete at a given index") {

                it("should notify the main observable") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: {
                        (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let newValue):
                                expect(newValue) == ["test1"]
                                done()
                            default: break
                            }
                        })
                        variable.removeAtIndex(1)
                    })
                }

                it("should notify the changes observable with the right type") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: {
                        (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .remove(let index, let element):
                                    expect(index) == 1
                                    expect(element) == "test2"
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.removeAtIndex(1)
                    })
                }
            }

            context("deleting the last element", {

                it("should notify the deletion to the main observable") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                expect(change) == ["test1"]
                                done()
                            default: break
                            }
                        })
                        variable.removeLast()
                    })
                }

                it("should notify the deletion to the changes observable with the right type") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .remove(let index, let element):
                                    expect(index) == 1
                                    expect(element) == "test2"
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.removeLast()
                    })
                }

            })

            context("deleting the first element", {
                it("should notify the deletion to the main observable") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                expect(change) == ["test2"]
                                done()
                            default: break
                            }
                        })
                        variable.removeFirst()
                    })
                }

                it("should notify the deletion to the changes observable with the right type") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .remove(let index, let element):
                                    expect(index) == 0
                                    expect(element) == "test1"
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.removeFirst()
                    })
                }
            })

            context("remove all elements", {
                it("should notify the deletion to the main observable") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                expect(change) == []
                                done()
                            default: break
                            }
                        })
                        variable.removeAll()
                    })
                }

                it("should notify the deletion to the changes observable with the right type") {
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .composite(let changes):
                                    let indexes = changes.map({$0.index()!})
                                    let elements = changes.map({$0.element()!})
                                    expect(indexes) == [0, 1]
                                    expect(elements) == ["test1", "test2"]
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.removeAll()
                    })
                }
            })

        }

        context("adding elements") { () -> Void in

            context("appending elements individually", { () -> Void in

                it("should notify about the change to the main observable", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let next):
                                expect(next) == ["test1", "test2", "test3"]
                                done()
                            default: break
                            }
                        })
                        variable.append("test3")
                    })
                })

                it("should notify the changes observable about the adition", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .insert(let index, let element):
                                    expect(index) == 2
                                    expect(element) == "test3"
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.append("test3")
                    })
                })

            })

            context("appending elements from another array", { () -> Void in

                it("should notify about the change to the main observable", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let next):
                                expect(next) == ["test1", "test2", "test3", "test4"]
                                done()
                            default: break
                            }
                        })
                        variable.appendContentsOf(["test3", "test4"])
                    })
                })

                it("should notify the changes observable about the adition", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .composite(let changes):
                                    let indexes = changes.map({$0.index()!})
                                    let elements = changes.map({$0.element()!})
                                    expect(indexes) == [2, 3]
                                    expect(elements) == ["test3", "test4"]
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.appendContentsOf(["test3", "test4"])
                    })
                })

            })

            context("inserting elements", { () -> Void in

                it("should notify about the change to the main observable", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let next):
                                expect(next) == ["test0", "test1", "test2"]
                                done()
                            default: break
                            }
                        })
                        variable.insert("test0", atIndex: 0)
                    })
                })

                it("should notify the changes observable about the adition", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .insert(let index, let element):
                                    expect(index) == 0
                                    expect(element) == "test0"
                                    done()
                                default: break
                                }
                            default: break
                            }
                        })
                        variable.insert("test0", atIndex: 0)
                    })
                })

            })

            context("replacing elements", { () -> Void in

                it("should notify about the change to the main observable", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.observable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let next):
                                expect(next) == ["test3", "test4"]
                                done()
                            default: break
                            }
                        })
                        let range = CountableRange<Int>(0...1)
                        variable.replace(range, with: ["test3", "test4"])
                    })
                })

                it("should notify the changes producer about the adition", closure: { () -> () in
                    let array: [String] = ["test1", "test2"]
                    let variable: CollectionVariable<String> = CollectionVariable(array)
                    waitUntil(action: { (done) -> Void in
                        _ = variable.changesObservable.subscribe({ (event) -> Void in
                            switch event {
                            case .next(let change):
                                switch change {
                                case .composite(let changes):
                                    let indexes = changes.map({$0.index()!})
                                    let elements = changes.map({$0.element()!})
                                    expect(indexes) == [0, 0, 1, 1]
                                    expect(elements) == ["test1", "test3", "test2", "test4"]
                                default: break
                                }
                            default: break
                            }
                        })
                        let range = CountableRange<Int>(0...1)
                        variable.replace(range, with: ["test3", "test4"])
                    })

                })
                
            })
            
        }
        
    }
    
}
