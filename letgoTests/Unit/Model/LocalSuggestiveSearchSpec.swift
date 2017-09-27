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
        var sut : LocalSuggestiveSearch!
        
        describe("LocalSuggestiveSearch") {
            describe("init with parameters") {
                var name: String!
                var category: ListingCategory!
                
                beforeEach {
                    name = String.makeRandom()
                    category = ListingCategory.makeMock()
                    sut = LocalSuggestiveSearch(name: name,
                                                category: category)
                }
                
                it("has the same name passed into initializer") {
                    expect(sut.name) == name
                }
                it("has the same category passed into initializer") {
                    expect(sut.category!.rawValue) == category.rawValue
                }
            }
            
            describe("init with suggestive search") {
                var suggestiveSearch: SuggestiveSearch!
                beforeEach {
                    suggestiveSearch = LocalSuggestiveSearch(name: String.makeRandom(),
                                                             category: ListingCategory.makeMock())
                    sut = LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
                }
                
                it("has the same name suggestiveSearch has") {
                    expect(sut.name) == suggestiveSearch.name
                }
                it("has the same category suggestiveSearch has") {
                    expect(sut.category!.rawValue) == suggestiveSearch.category!.rawValue
                }
            }
            
            describe("NSCoding") {
                var name: String!
                var data: Data!
                
                context("without category") {
                    beforeEach {
                        name = String.makeRandom()
                        sut = LocalSuggestiveSearch(name: name,
                                                    category: nil)
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
                        it("decodes the same name it previously coded") {
                            expect(decodedSut.name) == name
                        }
                        it("decodes nil category") {
                            expect(decodedSut.category).to(beNil())
                        }
                    }
                }
                
                
                context("with category") {
                    var category: ListingCategory!
                    
                    beforeEach {
                        name = String.makeRandom()
                        category = ListingCategory.makeMock()
                        sut = LocalSuggestiveSearch(name: name,
                                                    category: category)
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
                        it("decodes the same name it previously coded") {
                            expect(decodedSut.name) == name
                        }
                        it("decodes the same category it previously coded") {
                            expect(decodedSut.category!.rawValue) == category!.rawValue
                        }
                    }
                }
            }
        }
    }
}
