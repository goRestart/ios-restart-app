//
//  LocalSuggestiveSearchSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 26/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
@testable import LetGoGodMode
import LGCoreKit

class LocalSuggestiveSearchSpec: QuickSpec {
    override func spec() {
        var sut: LocalSuggestiveSearch!
        
        describe("LocalSuggestiveSearch") {
            describe("init with suggestive search") {
                var suggestiveSearch: SuggestiveSearch!
                
                beforeEach {
                    suggestiveSearch = SuggestiveSearch.makeMock()
                    sut = LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
                }

                it("has the same suggestive search") {
                    expect(sut.suggestiveSearch) == suggestiveSearch
                }
            }
            
            describe("NSCoding") {
                var suggestiveSearch: SuggestiveSearch!
                var data: Data!
                
                context("term") {
                    beforeEach {
                        suggestiveSearch = SuggestiveSearch.term(name: String.makeRandom())
                        sut = LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
                        data = NSKeyedArchiver.archivedData(withRootObject: sut)
                    }
                    
                    describe("encoding") {
                        it("encodes the object into data") {
                            expect(data).notTo(beNil())
                        }
                    }
                    
                    describe("decoding") {
                        var decodedSut: LocalSuggestiveSearch!
                        
                        beforeEach {
                            decodedSut = NSKeyedUnarchiver.unarchiveObject(with: data) as? LocalSuggestiveSearch
                        }
                        
                        it("decodes the data into an object") {
                            expect(decodedSut).notTo(beNil())
                        }
                        it("decodes the same suggestive search") {
                            expect(decodedSut.suggestiveSearch) == suggestiveSearch
                        }
                    }
                }
                
                context("category") {
                    beforeEach {
                        suggestiveSearch = SuggestiveSearch.category(category: ListingCategory.makeMock())
                        sut = LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
                        data = NSKeyedArchiver.archivedData(withRootObject: sut)
                    }
                    
                    describe("encoding") {
                        it("encodes the object into data") {
                            expect(data).notTo(beNil())
                        }
                    }
                    
                    describe("decoding") {
                        var decodedSut: LocalSuggestiveSearch!
                        
                        beforeEach {
                            decodedSut = NSKeyedUnarchiver.unarchiveObject(with: data) as? LocalSuggestiveSearch
                        }
                        
                        it("decodes the data into an object") {
                            expect(decodedSut).notTo(beNil())
                        }
                        it("decodes the same suggestive search") {
                            expect(decodedSut.suggestiveSearch) == suggestiveSearch
                        }
                    }
                }
                
                context("term with category") {
                    beforeEach {
                        suggestiveSearch = SuggestiveSearch.termWithCategory(name: String.makeRandom(),
                                                                             category: ListingCategory.makeMock())
                        sut = LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
                        data = NSKeyedArchiver.archivedData(withRootObject: sut)
                    }
                    
                    describe("encoding") {
                        it("encodes the object into data") {
                            expect(data).notTo(beNil())
                        }
                    }
                    
                    describe("decoding") {
                        var decodedSut: LocalSuggestiveSearch!
                        
                        beforeEach {
                            decodedSut = NSKeyedUnarchiver.unarchiveObject(with: data) as? LocalSuggestiveSearch
                        }
                        
                        it("decodes the data into an object") {
                            expect(decodedSut).notTo(beNil())
                        }
                        it("decodes the same suggestive search") {
                            expect(decodedSut.suggestiveSearch) == suggestiveSearch
                        }
                    }
                }
                
                context("array") {
                    var array: [LocalSuggestiveSearch]!
                    
                    beforeEach {
                        array = [LocalSuggestiveSearch(suggestiveSearch: SuggestiveSearch.term(name: String.makeRandom())),
                                 LocalSuggestiveSearch(suggestiveSearch: SuggestiveSearch.category(category: ListingCategory.makeMock())),
                                 LocalSuggestiveSearch(suggestiveSearch: SuggestiveSearch.termWithCategory(name: String.makeRandom(),
                                                                                                           category: ListingCategory.makeMock()))]
                        data = NSKeyedArchiver.archivedData(withRootObject: array)
                    }
                    
                    describe("encoding") {
                        it("encodes the object into data") {
                            expect(data).notTo(beNil())
                        }
                    }

                    describe("decoding") {
                        var decodedSut: [LocalSuggestiveSearch]!
                        
                        beforeEach {
                            decodedSut = NSKeyedUnarchiver.unarchiveObject(with: data) as? [LocalSuggestiveSearch]
                        }
                        
                        it("decodes the data into an object") {
                            expect(decodedSut).notTo(beNil())
                        }
                        it("decodes the same suggestive searches") {
                            expect(decodedSut.flatMap { $0.suggestiveSearch }) == array.flatMap { $0.suggestiveSearch }
                        }
                    }
                }
            }
        }
    }
}
