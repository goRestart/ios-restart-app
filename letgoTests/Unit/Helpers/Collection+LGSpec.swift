//
//  Collection+LGSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 22/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class CollectionLGSpec: QuickSpec {
    override func spec() {
        var sut: [ColData]!
        var attr1s: [String] {
            return sut.map { $0.attribute1 }
        }

        let matcher: (ColData, ColData) -> Bool = {
            return $0.attribute1 == $1.attribute1
        }

        let comparator: (ColData, ColData) -> Bool = { (item1, item2) -> Bool in
            if item1.attribute2 == nil && item2.attribute2 != nil { return true }
            guard let attr1 = item1.attribute2, let attr2 = item2.attribute2 else { return false }
            return attr1 > attr2
        }

        describe("Collection + LG methods") {
            describe("merge") {
                context("empty source") {
                    beforeEach {
                        sut = []
                    }
                    context("empty collection") {
                        beforeEach {
                            let collection = [ColData]()
                            sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                        }
                        it("result is empty") {
                            expect(sut).to(beEmpty())
                        }
                    }
                    context("populated collection") {
                        context("only nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", nil))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", nil))
                                collection.append(ColData("d", nil))
                                collection.append(ColData("e", nil))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is exactly the new collection") {
                                expect(attr1s) == ["a","b","c","d","e"]
                            }
                        }
                        context("only non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", 4))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("no ordering applied, result is exactly the new collection") {
                                expect(attr1s) == ["a","b","c","d","e"]
                            }
                        }
                    }
                }
                context("populated nil order objets source") {
                    beforeEach {
                        sut = []
                        sut.append(ColData("A", nil))
                        sut.append(ColData("B", nil))
                        sut.append(ColData("C", nil))
                        sut.append(ColData("D", nil))
                        sut.append(ColData("E", nil))
                    }
                    context("empty collection") {
                        beforeEach {
                            let collection = [ColData]()
                            sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                        }
                        it("result is the original collection") {
                            expect(attr1s) == ["A","B","C","D","E"]
                        }
                    }
                    context("populated collection") {
                        context("only nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", nil))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", nil))
                                collection.append(ColData("d", nil))
                                collection.append(ColData("e", nil))
                                collection.append(ColData("D", nil))
                                collection.append(ColData("E", nil))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is original + appended collection") {
                                expect(attr1s) == ["A","B","C","D","E","a","b","c","d","e"]
                            }
                        }
                        context("only non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", 4))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                collection.append(ColData("D", 3))
                                collection.append(ColData("E", 20))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection") {
                                expect(attr1s) == ["A","B","C","E","d","e","b","D","a","c"]
                            }
                        }
                        context("nil and non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                collection.append(ColData("D", 3))
                                collection.append(ColData("E", 20))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection (nils first)") {
                                expect(attr1s) == ["A","B","C","b","E","d","e","D","a","c"]
                            }
                        }
                    }
                }
                context("populated non nil order objets source") {
                    beforeEach {
                        sut = []
                        sut.append(ColData("A", 10))
                        sut.append(ColData("B", 2))
                        sut.append(ColData("C", 30))
                        sut.append(ColData("D", 3))
                        sut.append(ColData("E", 4))
                    }
                    context("empty collection") {
                        beforeEach {
                            let collection = [ColData]()
                            sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                        }
                        it("result is the original collection") {
                            expect(attr1s) == ["A","B","C","D","E"]
                        }
                    }
                    context("populated collection") {
                        context("only nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", nil))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", nil))
                                collection.append(ColData("d", nil))
                                collection.append(ColData("e", nil))
                                collection.append(ColData("D", nil))
                                collection.append(ColData("E", nil))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection (nils first)") {
                                expect(attr1s) == ["D","E","a","b","c","d","e","C","A","B",]
                            }
                        }
                        context("only non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", 4))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                collection.append(ColData("D", 5))
                                collection.append(ColData("E", 20))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection") {
                                expect(attr1s) == ["C","E","A","d","e","D","b","B","a","c"]
                            }
                        }
                        context("nil and non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                collection.append(ColData("D", nil))
                                collection.append(ColData("E", 20))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection (nils first)") {
                                expect(attr1s) == ["D","b","C","E","A","d","e","B","a","c"]
                            }
                        }
                    }
                }
                context("populated nil and non nil order objets source") {
                    beforeEach {
                        sut = []
                        sut.append(ColData("A", 10))
                        sut.append(ColData("B", nil))
                        sut.append(ColData("C", 30))
                        sut.append(ColData("D", nil))
                        sut.append(ColData("E", 4))
                    }
                    context("empty collection") {
                        beforeEach {
                            let collection = [ColData]()
                            sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                        }
                        it("result is the original collection") {
                            expect(attr1s) == ["A","B","C","D","E"]
                        }
                    }
                    context("populated collection") {
                        context("only nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", nil))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", nil))
                                collection.append(ColData("d", nil))
                                collection.append(ColData("e", nil))
                                collection.append(ColData("D", nil))
                                collection.append(ColData("E", nil))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is first original list nil objects, then appended nil and then non nil ordered") {
                                expect(attr1s) == ["B","D","E","a","b","c","d","e","C","A"]
                            }
                        }
                        context("only non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", 4))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                collection.append(ColData("D", 5))
                                collection.append(ColData("E", 20))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection") {
                                expect(attr1s) == ["B","C","E","A","d","e","D","b","a","c"]
                            }
                        }
                        context("nil and non nil order objects") {
                            beforeEach {
                                var collection = [ColData]()
                                collection.append(ColData("a", 1))
                                collection.append(ColData("b", nil))
                                collection.append(ColData("c", 1))
                                collection.append(ColData("d", 8))
                                collection.append(ColData("e", 6))
                                collection.append(ColData("D", 5))
                                collection.append(ColData("E", 20))
                                sut.merge(another: collection, matcher: matcher, sortBy: comparator)
                            }
                            it("result is ordered merged collection (nils first)") {
                                expect(attr1s) == ["B","b","C","E","A","d","e","D","a","c"]
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ColData {
    let attribute1: String
    let attribute2: Int?

    init(_ attr1: String, _ attr2: Int?) {
        attribute1 = attr1
        attribute2 = attr2
    }
}

