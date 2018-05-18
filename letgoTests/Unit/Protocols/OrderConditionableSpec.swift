//
//  OrderConditionableSpec.swift
//  letgoTests
//
//  Created by Stephen Walsh on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import LetGoGodMode

class OrderConditionableSpec: QuickSpec {
    
    override func spec() {
        
        describe("OrderConditionable") {
            var sut: MockOrderConditionable!

            context("OrderConditionable with partially filled array") {
                beforeEach {
                    sut = MockOrderConditionable(items: ["1", "2"])
                }
                
                describe("init") {
                    // let's test what we expect from the init
                    it("should have a count of 2") {
                        expect(sut.orderableDatasource.count).to(equal(2))
                    }
                }
                
                describe("insert") {
                    context("at last position") {
                        beforeEach {
                            sut.insert(item: "3", withOrderCondition: OrderCondition.last)
                        }
                        
                        it("should have 3 items") {
                            expect(sut.orderableDatasource.count).to(equal(3))
                        }
                        it("should preserve the position of the previous items") {
                            let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                            expect(indexes).to(equal([0, 1]))
                        }
                        it("should insert the new item at the end") {
                            expect(sut.indexOf(item: "3")).to(equal(2))
                        }
                    }
                    context("at first position") {
                        beforeEach {
                            sut.insert(item: "3", withOrderCondition: OrderCondition.first)
                        }
                        
                        it("should have 3 items") {
                            expect(sut.orderableDatasource.count).to(equal(3))
                        }
                        it("should shift the position of the existing items") {
                            let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                            expect(indexes).to(equal([1, 2]))
                        }
                        it("should insert the new item at the start") {
                            expect(sut.indexOf(item: "3")).to(equal(0))
                        }
                    }
                    describe("at exact position") {
                        context("with valid index") {
                            beforeEach {
                                sut.insert(item: "3", withOrderCondition: OrderCondition.exactly(index: 1))
                            }
                            
                            it("should have 3 items") {
                                expect(sut.orderableDatasource.count).to(equal(3))
                            }
                            it("should shift the position of the existing items accordingly") {
                                let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                                expect(indexes).to(equal([0, 2]))
                            }
                            it("should insert the new item at the given index") {
                                expect(sut.indexOf(item: "3")).to(equal(1))
                            }
                        }
                        context("with invalid index") {
                            beforeEach {
                                sut.insert(item: "3", withOrderCondition: OrderCondition.exactly(index: 10))
                            }
                            
                            it("should have 3 items") {
                                expect(sut.orderableDatasource.count).to(equal(3))
                            }
                            it("should preserve the previous order") {
                                let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                                expect(indexes).to(equal([0, 1]))
                            }
                            it("should insert the new item at the end") {
                                expect(sut.indexOf(item: "3")).to(equal(2))
                            }
                        }
                    }
                    describe("after") {
                        context("a present item") {
                            beforeEach {
                                sut.insert(item: "3", withOrderCondition: OrderCondition.after(item: "1"))
                            }
                            
                            it("should have 3 items") {
                                expect(sut.orderableDatasource.count).to(equal(3))
                            }
                            it("should shift the position of the existing items accordingly") {
                                let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                                expect(indexes).to(equal([0, 2]))
                            }
                            it("should insert the new item after the given parameter") {
                                expect(sut.indexOf(item: "3")).to(equal(1))
                            }
                        }
                        context("an present item that isn't present") {
                            beforeEach {
                                sut.insert(item: "3", withOrderCondition: OrderCondition.after(item: "4"))
                            }
                            
                            it("should have 3 items") {
                                expect(sut.orderableDatasource.count).to(equal(3))
                            }
                            it("should preserve the previous order") {
                                let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                                expect(indexes).to(equal([0, 1]))
                            }
                            it("should insert the new item at the end") {
                                expect(sut.indexOf(item: "3")).to(equal(2))
                            }
                        }
                    }
                    describe("before") {
                        context("a present item") {
                            beforeEach {
                                sut.insert(item: "3", withOrderCondition: OrderCondition.before(item: "2"))
                            }
                            
                            it("should have 3 items") {
                                expect(sut.orderableDatasource.count).to(equal(3))
                            }
                            it("should shift the position of the existing items accordingly") {
                                let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                                expect(indexes).to(equal([0, 2]))
                            }
                            it("should insert the new item after the given parameter") {
                                expect(sut.indexOf(item: "3")).to(equal(1))
                            }
                        }
                        context("an present item that isn't present") {
                            beforeEach {
                                sut.insert(item: "3", 
                                           withOrderCondition: OrderCondition.before(item: "4"))
                            }
                            
                            it("should have 3 items") {
                                expect(sut.orderableDatasource.count).to(equal(3))
                            }
                            it("should preserve the previous order") {
                                let indexes = [sut.indexOf(item: "1"), sut.indexOf(item: "2")]
                                expect(indexes).to(equal([0, 1]))
                            }
                            it("should insert the new item at the end") {
                                expect(sut.indexOf(item: "3")).to(equal(2))
                            }
                        }
                    }
                    
                }
            }
        }
    }
}
